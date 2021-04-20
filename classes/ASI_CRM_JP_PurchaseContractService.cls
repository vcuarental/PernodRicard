public without Sharing class ASI_CRM_JP_PurchaseContractService {
    
    public static final String SEARCH_REPORT_NAME = 'Purchase_Contract_Line_Items_For_Search';
    public static final String EXPORT_REPORT_NAME = 'Purchase_Contract_Line_Items_For_Export2';
    public static final String SALES_STAFF_NO = '0000';
    
    private final static String HEADER_PURCHASE_CONTRACT_NAME = 'Purchase Contract: Contract No.';
    private final static String HEADER_PURCHASE_CONTRACT_LINE_ITEM_NAME = 'Purchase Contract Line Item: Ref No.';
    private final static String HEADER_OWNER = 'Owner';
    private final static String HEADER_STAFF_CODE = 'Staff Code';
    private final static String HEADER_CANCEL = 'Cancel?';
    private final static String HEADER_PAY_TO_NAME = 'Pay To';
    private final static String HEADER_ITEM_GROUP_NAME = 'Item Group';
    private final static String HEADER_REBATE_TYPE = 'Rebate Type';
    private final static String HEADER_CURRENT_DIRECT_REBATE = 'Current Direct Rebate';
    private final static String HEADER_CURRENT_INDIRECT_REBATE = 'Current Indirect Rebate';
    private final static String HEADER_TARGET_VOLUME_UNIT = 'Target Volume Unit';
    private final static String HEADER_UNIT_PRICE_COST = 'Unit Price/Cost';
    private final static String HEADER_REMARKS = 'Remarks';
    private final static String HEADER_SHIP_TO = 'BS/Retailer/Ship To';
    private final static String HEADER_WHOLESALER = 'Wholesaler';
    private final static String HEADER_FIXED_SPOT = 'Fixed/Spot';
    private final static String HEADER_START_DATE = 'Start Date';
    private final static String HEADER_END_DATE = 'End Date';
    private final static String HEADER_PURCHASE_CONTRACT_RECORD_TYPE = 'Purchase Contract: Record Type';
    private final static String HEADER_RSP_BEFORE_REBATE = 'RSP before Rebate';
    private final static String HEADER_RSP_AFTER_REBATE = 'RSP after Rebate';
    
    private final static Map<String, Integer> csvColumnHeaderIndexMap = new Map<String, Integer> {
        HEADER_PURCHASE_CONTRACT_NAME => 0,
            HEADER_PURCHASE_CONTRACT_LINE_ITEM_NAME => 1,
            HEADER_OWNER => 2,
            HEADER_STAFF_CODE => 3,
            HEADER_CANCEL => 4,
            HEADER_PAY_TO_NAME => 5,
            HEADER_ITEM_GROUP_NAME => 6,
            HEADER_REBATE_TYPE => 7,
            HEADER_CURRENT_DIRECT_REBATE => 8,
            HEADER_CURRENT_INDIRECT_REBATE => 9,
            HEADER_TARGET_VOLUME_UNIT => 10,
            HEADER_UNIT_PRICE_COST => 11,
            HEADER_REMARKS => 12,
            HEADER_SHIP_TO => 13,
            HEADER_WHOLESALER => 14,
            HEADER_FIXED_SPOT => 15,
            HEADER_START_DATE => 16,
            HEADER_END_DATE => 17,
            HEADER_PURCHASE_CONTRACT_RECORD_TYPE => 18,
            HEADER_RSP_BEFORE_REBATE => 19,
            HEADER_RSP_AFTER_REBATE => 20
            };
                public static final String PURCHASE_CONTRACT_STATUS_DRAFT = 'Draft';
    
    public class PurchaseContractImportException extends Exception {}
    
    public static void cloneAll(
        ASI_CRM_Purchase_Contract_Line_Item__c reportSearchForm,
        ASI_CRM_JP_PurchaseContractService.ReportParameters reportParameters,
        String batchId
    ) {
        system.debug('reportSearchForm=================>'+reportSearchForm);
        system.debug('reportParameters=================>'+reportParameters);
        system.debug('batchId=================>'+batchId);
        final Set<Id> purchaseContractLineItemIds = ASI_CRM_JP_PurchaseContractService.getContractLineItemIdsFromReport(
            reportSearchForm, reportParameters
        );
        System.debug('purchaseContractLineItemIds========>'+ purchaseContractLineItemIds);
        final Set<Id> validIds = filterPurchaseContractItemsByValidRecordTypes(purchaseContractLineItemIds);
        
        System.debug('validIds:::' + validIds);
        final Map<Id, Set<Id>> purchaseContractIdItemsIdSetMap =
            ASI_CRM_JP_PurchaseContractService.getPurchaseContractIdItemsIdSetMap(validIds);
        
        final List<ASI_CRM_Purchase_Contract__c> purchaseContractsToClone =
            getPurchaseContractsToClone(purchaseContractIdItemsIdSetMap.keySet());
        
        System.debug('purchaseContractsToClone:::' + purchaseContractsToClone.size());
        System.debug('purchaseContractsToClone:::' + purchaseContractsToClone);
        
        if (purchaseContractsToClone.size() > 70) {
            throw new PurchaseContractImportException('Too many contracts to clone');
        }
        
        final List<ASI_CRM_Purchase_Contract__c> clonedPurchaseContracts = clonePurchaseContracts(
            purchaseContractsToClone, batchId
        );
        
        final Map<Id, Id> oldNewPurchaseContractIdMap = getOldNewPurchaseContractIdMap(clonedPurchaseContracts);
        
        System.debug('oldNewPurchaseContractIdMap keyset:::' + oldNewPurchaseContractIdMap.keySet());
        System.debug('oldNewPurchaseContractIdMap values:::' + oldNewPurchaseContractIdMap.values());
        
        final List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItemsToClone =
            getPurchaseContractLineItemsToClone(oldNewPurchaseContractIdMap.keySet());
        
        System.debug('purchaseContractLineItemsToClone:::' + purchaseContractLineItemsToClone.size());
        System.debug('purchaseContractLineItemsToClone:::' + purchaseContractLineItemsToClone);
        
        if (purchaseContractLineItemsToClone.size() > 350) {
            throw new PurchaseContractImportException('Too many contract items to clone');
        }
        
        final List<ASI_CRM_Purchase_Contract_Line_Item__c> clonedPurchaseContractLineItems =
            clonePurchaseContractLineItems(oldNewPurchaseContractIdMap, purchaseContractLineItemsToClone);
        
        updatePurchaseContractStatusOwner(clonedPurchaseContractLineItems);
        
    }
    
    @testVisible
    private static Map<Id, Id> getOldNewPurchaseContractIdMap(
        List<ASI_CRM_Purchase_Contract__c> clonedPurchaseContracts
    ) {
        
        final Map<Id, Id> oldNewPurchaseContractIdMap = new Map<Id, Id>();
        
        for (ASI_CRM_Purchase_Contract__c purchaseContract : clonedPurchaseContracts) {
            oldNewPurchaseContractIdMap.put(purchaseContract.getCloneSourceId(), purchaseContract.Id);
        }
        
        return oldNewPurchaseContractIdMap;
    }
    
    @testVisible
    private static List<ASI_CRM_Purchase_Contract__c> getPurchaseContractsToClone(Set<Id> purchaseContractIds) {
        System.debug('No of Purchase Contract Ids to be cloned: ' + purchaseContractIds.size());
        
        final Set<String> excludedRecordTypeApiNames = getPurchaseContractRecordTypesToExclude();
        System.debug('excludedRecordTypeApiNames ' + excludedRecordTypeApiNames);
        
        final String queryString = ASI_CRM_QueryUtil.getSelectAllFieldsQueryString(
            ASI_CRM_Purchase_Contract__c.sObjectType,
            ' WHERE Id IN :purchaseContractIds' +
            ' AND RecordType.DeveloperName NOT IN :excludedRecordTypeApiNames'
        );
        System.debug('Purchase Contract Line Items Query String ' + queryString);
        
        final List<ASI_CRM_Purchase_Contract__c> purchaseContractsToClone = Database.query(queryString);
        return purchaseContractsToClone;
    }
    
    @testVisible
    private static List<ASI_CRM_Purchase_Contract_Line_Item__c> getPurchaseContractLineItemsToClone(
        Set<Id> allPurchaseContractLineIds
    ) {
        System.debug('No of Purchase Contract Line Items to clone: ' + allPurchaseContractLineIds.size());
        
        final Set<String> excludedRecordTypeApiNames = getPurchaseContractRecordTypesToExclude();
        System.debug('excludedRecordTypeApiNames ' + excludedRecordTypeApiNames);
        
        final String itemsQueryString = ASI_CRM_QueryUtil.getSelectAllFieldsQueryString(
            ASI_CRM_Purchase_Contract_Line_Item__c.sObjectType,
            ' WHERE ASI_CRM_Purchase_Contract__c IN :allPurchaseContractLineIds' +
            ' AND ASI_CRM_Purchase_Contract__r.RecordType.DeveloperName NOT IN :excludedRecordTypeApiNames'
        );
        System.debug('Purchase Contract Line Items Query String ' + itemsQueryString);
        
        final List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItemsToClone = Database.query(
            itemsQueryString
        );
        for(ASI_CRM_Purchase_Contract_Line_Item__c i : purchaseContractLineItemsToClone) {
            System.debug('i.ASI_CRM_JP_Current_Direct_Supporting__c:::' + i.ASI_CRM_JP_Current_Direct_Supporting__c);
        }
        return purchaseContractLineItemsToClone;
    }
    
    @testVisible
    private static Set<String> getPurchaseContractRecordTypesToExclude() {
        
        final Set<String> excludedRecordTypeApiNames = new Set<String>{
            ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_SPTD_Contract.name(),
                ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_SPTD_Contract_Read_Only.name()
                };
                    
                    return excludedRecordTypeApiNames;
    }
    
    public static List<Database.SaveResult> updateContractLineItems(List<List<String>> csvRows) {
        
        final Set<String> contractLineItemNames = ASI_CRM_FileUploadHelper.getColumnValueSetFromCSVData(csvRows,
                                                                                                        csvColumnHeaderIndexMap.get(HEADER_PURCHASE_CONTRACT_LINE_ITEM_NAME));
        final Set<String> payToNames = ASI_CRM_FileUploadHelper.getColumnValueSetFromCSVData(csvRows,
                                                                                             csvColumnHeaderIndexMap.get(HEADER_PAY_TO_NAME));
        final Set<String> itemGroupNames = ASI_CRM_FileUploadHelper.getColumnValueSetFromCSVData(csvRows,
                                                                                                 csvColumnHeaderIndexMap.get(HEADER_ITEM_GROUP_NAME));
        final Set<String> contractNames = ASI_CRM_FileUploadHelper.getColumnValueSetFromCSVData(csvRows,
                                                                                                csvColumnHeaderIndexMap.get(HEADER_PURCHASE_CONTRACT_NAME));
        
        final Set<String> itemGroupCodesFromNames = getItemGroupCodeFromName(itemGroupNames);
        
        final Map<String, ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItemNameObjectMap =
            getPurchaseContractLineItemNameObjectMap(contractLineItemNames);
        final Map<String, ASI_CRM_Pay_To__c> payToNameObjectMap =
            getPayToNameObjectMap(payToNames);
        final Map<String, ASI_CRM_Pay_To__c> payToNumberObjectMap =
            getPayToNumberObjectMap(payToNames);
        final Map<String, ASI_MFM_Item_Group__c> itemGroupNameObjectMap =
            getItemGroupNameObjectMap(itemGroupNames);
        final Map<String, ASI_MFM_Item_Group__c> itemGroupCodeObjectMap =
            getItemGroupCodeObjectMap(itemGroupNames);
        //		final Map<String, ASI_MFM_Item_Group__c> itemGroupCodeFromNameObjectMap =
        //				getItemGroupCodeFromNameObjectMap(itemGroupCodesFromNames);
        final Map<String, ASI_CRM_Purchase_Contract__c> purchaseContractNameObjectMap =
            getPurchaseContractNameObjectMap(contractNames);
        
        final List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItems =
            new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        
        final Map<Id, Boolean> purchaseContractIdCancelFlagMap = new Map<Id, Boolean>();
        
        Integer rowCounter = -1;
        for (List<String> csvRow : csvRows) {
            
            rowCounter++;
            
            final String purchaseContractLineItemName =
                csvRow.get(csvColumnHeaderIndexMap.get(HEADER_PURCHASE_CONTRACT_LINE_ITEM_NAME));
            final String payToName = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_PAY_TO_NAME));
            final String itemGroupName = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_ITEM_GROUP_NAME));
            final String rebateType = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_REBATE_TYPE));
            final String currentDirectRebate = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_CURRENT_DIRECT_REBATE));
            final String currentIndirectRebate =
                csvRow.get(csvColumnHeaderIndexMap.get(HEADER_CURRENT_INDIRECT_REBATE));
            final String targetVolumeUnit = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_TARGET_VOLUME_UNIT));
            final String unitPriceCost = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_UNIT_PRICE_COST));
            final String remarks = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_REMARKS));
            final String cancel = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_CANCEL));
            final String purchaseContractName = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_PURCHASE_CONTRACT_NAME));
            final String staffCode = csvRow.get(csvColumnHeaderIndexMap.get(HEADER_STAFF_CODE));
            
            final ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem =
                purchaseContractLineItemNameObjectMap.get(purchaseContractLineItemName);
            
            final ASI_CRM_Purchase_Contract__c purchaseContract =
                purchaseContractNameObjectMap.get(purchaseContractName);
            
            
            if (purchaseContract == null) {
                ASI_CRM_PageUtil.showError(getRowDetail(rowCounter) + ': Invalid purchase contract name');
                continue;
            }
            
            if (purchaseContractLineItem == null) {
                purchaseContractLineItem = new ASI_CRM_Purchase_Contract_Line_Item__c();
            }
            
            ASI_MFM_Item_Group__c itemGroup = itemGroupNameObjectMap.get(itemGroupName);
            if (itemGroup == null) itemGroup = itemGroupCodeObjectMap.get(itemGroupName);
            
            ASI_CRM_Pay_To__c payTo = payToNameObjectMap.get(payToName);
            if (payTo == null) payTo = payToNumberObjectMap.get(payToName);
            
            if (payTo != null) {
                purchaseContractLineItem.ASI_CRM_Pay_To__c = payTo.Id;
            } else {
                purchaseContractLineItem.ASI_CRM_Pay_To__c = null;
            }
            
            if (itemGroup != null) {
                purchaseContractLineItem.ASI_CRM_Item_Group__c = itemGroup.Id;
            } else {
                purchaseContractLineItem.ASI_CRM_Item_Group__c = null;
            }
            
            purchaseContractLineItem.ASI_CRM_Rebate_Type__c = rebateType;
            purchaseContractLineItem.ASI_CRM_Current_Direct_Rebate__c = getDoubleValue(currentDirectRebate);
            purchaseContractLineItem.ASI_CRM_Current_Indirect_Rebate__c = getDoubleValue(currentIndirectRebate);
            purchaseContractLineItem.ASI_CRM_Target_Volume_Unit__c = getDoubleValue(targetVolumeUnit);
            purchaseContractLineItem.ASI_CRM_Unit_Price__c = getDoubleValue(unitPriceCost);
            purchaseContractLineItem.ASI_CRM_Remarks__c = remarks;
            purchaseContractLineItem.ASI_CRM_Cancel__c = '1'.equals(cancel) ? true : false;
            purchaseContractLineItem.ASI_CRM_Purchase_Contract__c = purchaseContract.Id;
            purchaseContractLineItem.ASI_CRM_Staff_Code__c = staffCode;
            
            if (String.isNotBlank(purchaseContractLineItem.Id)) {
                purchaseContractLineItems.add(purchaseContractLineItem);
            }
        }
        
        List<Database.SaveResult> updateResults;
        //try {
            updateResults = Database.update(purchaseContractLineItems, false);
        //} catch (Exception e) {
           // System.debug(e.getStackTraceString());
        //}
        
        rowCounter = -1;
        for (Database.SaveResult updateResult : updateResults) {
            rowCounter++;
            
            if (updateResult.isSuccess()) continue;
            
            final List<String> errors = new List<String>();
            for (Database.Error error : updateResult.getErrors()) {
                errors.add(getRowDetail(rowCounter) + ': ' + error.getMessage());
            }
            
            ASI_CRM_PageUtil.showError(String.join(errors, ', '));
        }
        
        
        updatePurchaseContractStatusOwner(purchaseContractLineItems);
        
        
        return updateResults;
    }
    
    @testVisible
    private static void updatePurchaseContractStatusOwner(
        List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItems
    ) {
        
        final Set<Id> canceledPurchaseContractIds = getCanceledPurchaseContractIds(purchaseContractLineItems);
        final Map<Id, Id> purchaseContractOwnerIdMap = getPurchaseContractOwnerIdMap(purchaseContractLineItems);
        final Set<Id> purchaseContactIds = new Set<Id>();
        
        purchaseContactIds.addAll(canceledPurchaseContractIds);
        purchaseContactIds.addAll(purchaseContractOwnerIdMap.keySet());
        
        final List<ASI_CRM_Purchase_Contract__c> purchaseContracts =
            ASI_CRM_JP_UtilityService.findPurchaseContractByIds(purchaseContactIds);
        
        for (ASI_CRM_Purchase_Contract__c purchaseContract : purchaseContracts) {
            final Id purchaseContractId = purchaseContract.Id;
            
            if (canceledPurchaseContractIds.contains(purchaseContractId)) {
                purchaseContract.ASI_CRM_Status__c = 'Cancelled';
            }
            
            if (purchaseContractOwnerIdMap.get(purchaseContractId) != null) {
                purchaseContract.OwnerId = purchaseContractOwnerIdMap.get(purchaseContractId);
            }
        }
        
        try {
            update purchaseContracts;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
        }
    }
    
    @testVisible
    private static Set<Id> getCanceledPurchaseContractIds(
        List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractItems
    ) {
        final Set<Id> purchaseContractIds = new Set<Id>();
        
        for (ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractItem : purchaseContractItems) {
            if (purchaseContractItem.ASI_CRM_Cancel__c) {
                purchaseContractIds.add(purchaseContractItem.ASI_CRM_Purchase_Contract__c);
            }
        }
        return purchaseContractIds;
    }
    
    @testVisible
    private static Map<Id, Id> getPurchaseContractOwnerIdMap(
        List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractItems
    ) {
        
        final Set<String> staffCodes = ASI_CRM_JP_UtilityService.getObjectPropertySet(
            purchaseContractItems, ASI_CRM_Purchase_Contract_Line_Item__c.ASI_CRM_Staff_Code__c
        );
        
        final Map<String, User> staffCodeUserMap = ASI_CRM_JP_UtilityService.getStaffCodeUserMap(staffCodes);
        final Map<Id, Id> purchaseContractOwnerIdMap = new Map<Id, Id>();
        
        for (ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractItem : purchaseContractItems) {
            
            final Id purchaseContractId = purchaseContractItem.ASI_CRM_Purchase_Contract__c;
            final User user = staffCodeUserMap.get(purchaseContractItem.ASI_CRM_Staff_Code__c);
            
            if (purchaseContractOwnerIdMap.get(purchaseContractId) != null || user == null) continue;
            
            purchaseContractOwnerIdMap.put(
                purchaseContractId, user.Id
            );
        }
        
        return purchaseContractOwnerIdMap;
    }
    
    
    
    public static Set<Id> getContractLineItemIdsFromReport(
        ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem,
        ReportParameters reportParameters
    ) {
        
        final Id reportId = ASI_CRM_JP_DataService.getReportIdByApiName(SEARCH_REPORT_NAME);
        final Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        final Reports.ReportMetadata reportMetaData = describe.getReportMetadata();
        
        if (String.isNotBlank(purchaseContractLineItem.ASI_CRM_Item_Group__c)) {
            final ASI_MFM_Item_Group__c itemGroup = ASI_CRM_JP_DataService.getItemGroupById(
                purchaseContractLineItem.ASI_CRM_Item_Group__c
            );
            reportMetaData.getReportFilters().get(0).setValue(itemGroup.Name);
        }
        
        if (String.isNotBlank(purchaseContractLineItem.ASI_CRM_Purchase_Contract__r.ASI_CRM_BS_Retailer_Ship_To__c)) {
            final ASI_CRM_AccountsAdditionalField__c retailer = ASI_CRM_JP_DataService.getRetailerById(
                purchaseContractLineItem.ASI_CRM_Purchase_Contract__r.ASI_CRM_BS_Retailer_Ship_To__c
            );
            reportMetaData.getReportFilters().get(1).setValue(retailer.Name);
        }
        
        if (reportParameters.startDate != null) {
            reportMetaData.getReportFilters().get(2).setValue(reportParameters.startDate.format());
        }
        
        if (reportParameters.endToDate != null) {
            reportMetaData.getReportFilters().get(3).setValue(reportParameters.endToDate.format());
        }
        
        if (String.isNotBlank(reportParameters.recordTypeName)) {
            reportMetaData.getReportFilters().get(4).setValue(reportParameters.recordTypeName);
        }
        
        if (String.isNotBlank(purchaseContractLineItem.ASI_CRM_Purchase_Contract__r.ASI_CRM_Sales_Group__c)) {
            reportMetaData.getReportFilters().get(5).setValue(
                purchaseContractLineItem.ASI_CRM_Purchase_Contract__r.ASI_CRM_Sales_Group__c);
        }
        
        if (reportParameters.isEffective) {
            reportMetaData.getReportFilters().get(6).setValue('Activated,Approved,Complete');
        } else {
            reportMetaData.getReportFilters().get(6).setValue('');
        }
        
        if (reportParameters.isEffective) {
            //			reportMetaData.getReportFilters().get(7).setValue('');
            reportMetaData.getReportFilters().get(7).setValue(Date.today().format());
        } else {
            reportMetaData.getReportFilters().get(7).setValue(Date.newInstance(2000, 1, 1).format());
        }
        
        //reportMetaData.getReportFilters().get(8).setValue('');EndDate
        
        if (String.isNotBlank(purchaseContractLineItem.ASI_CRM_Purchase_Contract__r.OwnerId)) {
            final User owner =
                ASI_CRM_JP_DataService.getUserById(purchaseContractLineItem.ASI_CRM_Purchase_Contract__r.OwnerId);
            reportMetaData.getReportFilters().get(9).setValue(owner.Name); //Owner
            
        }
        
        
        printReportParameters(reportMetaData);
        
        final Reports.ReportResults results = Reports.ReportManager.runReport(reportId, reportMetaData, true);
        final Reports.Dimension dimension = results.getGroupingsDown();
        
        final Set<Id> rowIds = new Set<Id>();
        for (Reports.GroupingValue groupingValue : dimension.getGroupings()) {
            final String factMapKey = groupingValue.getKey() + '!T';
            final Reports.ReportFactWithDetails factDetails =
                (Reports.ReportFactWithDetails) results.getFactMap().get(factMapKey);
            
            for (Reports.ReportDetailRow detailRow : factDetails.getRows()) {
                final List<Reports.ReportDataCell> dataCells = detailRow.getDataCells();
                
                if (dataCells.isEmpty()) continue;
                
                rowIds.add(dataCells.get(0).getValue().toString());
            }
        }
        
        return rowIds;
    }
    
    @testVisible
    private static Map<String, ASI_CRM_Purchase_Contract_Line_Item__c> getPurchaseContractLineItemNameObjectMap(
        Set<String> lineItemNames) {
            final Map<String, ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItemNameObjectMap =
                new Map<String, ASI_CRM_Purchase_Contract_Line_Item__c>();
            
            for (
                ASI_CRM_Purchase_Contract_Line_Item__c lineItem
                :
                ASI_CRM_JP_DataService.getPurchaseContractLineItemsByName(lineItemNames)) {
                    purchaseContractLineItemNameObjectMap.put(lineItem.Name, lineItem);
                }
            
            return purchaseContractLineItemNameObjectMap;
        }
    
    @testVisible
    private static Map<String, ASI_CRM_Pay_To__c> getPayToNameObjectMap(Set<String> payToNames) {
        final Map<String, ASI_CRM_Pay_To__c> payToNameObjectMap = new Map<String, ASI_CRM_Pay_To__c>();
        
        for (ASI_CRM_Pay_To__c payTo : ASI_CRM_JP_DataService.getPayTosByNameOrNumber(payToNames)) {
            payToNameObjectMap.put(payTo.Name, payTo);
        }
        
        return payToNameObjectMap;
    }
    
    @testVisible
    private static Map<String, ASI_CRM_Pay_To__c> getPayToNumberObjectMap(Set<String> payToNames) {
        final Map<String, ASI_CRM_Pay_To__c> payToNameObjectMap = new Map<String, ASI_CRM_Pay_To__c>();
        
        for (ASI_CRM_Pay_To__c payTo : ASI_CRM_JP_DataService.getPayTosByNameOrNumber(payToNames)) {
            payToNameObjectMap.put(payTo.ASI_CRM_Pay_to_No__c, payTo);
        }
        
        return payToNameObjectMap;
    }
    
    @testVisible
    private static Map<String, ASI_MFM_Item_Group__c> getItemGroupNameObjectMap(Set<String> payToNames) {
        final Map<String, ASI_MFM_Item_Group__c> itemGroupNameObjectMap = new Map<String, ASI_MFM_Item_Group__c>();
        
        for (ASI_MFM_Item_Group__c itemGroup : ASI_CRM_JP_DataService.getItemGroupsByNameOrCode(payToNames)) {
            itemGroupNameObjectMap.put(itemGroup.Name, itemGroup);
        }
        
        return itemGroupNameObjectMap;
    }
    
    @testVisible
    private static Map<String, ASI_MFM_Item_Group__c> getItemGroupCodeObjectMap(Set<String> payToNames) {
        final Map<String, ASI_MFM_Item_Group__c> itemGroupNameObjectMap = new Map<String, ASI_MFM_Item_Group__c>();
        
        for (ASI_MFM_Item_Group__c itemGroup : ASI_CRM_JP_DataService.getItemGroupsByNameOrCode(payToNames)) {
            itemGroupNameObjectMap.put(itemGroup.ASI_MFM_Item_Group_Code__c, itemGroup);
        }
        
        return itemGroupNameObjectMap;
    }
    
    @testVisible
    private static Map<String, ASI_CRM_Purchase_Contract__c> getPurchaseContractNameObjectMap(
        Set<String> purchaseContractNames) {
            final Map<String, ASI_CRM_Purchase_Contract__c> purchaseContractNameObjectMap =
                new Map<String, ASI_CRM_Purchase_Contract__c>();
            
            for (
                ASI_CRM_Purchase_Contract__c purchaseContract
                :
                ASI_CRM_JP_DataService.getPurchaseContractsByName(purchaseContractNames)) {
                    purchaseContractNameObjectMap.put(purchaseContract.Name, purchaseContract);
                }
            
            return purchaseContractNameObjectMap;
        }
    
    @testVisible
    private static List<ASI_CRM_Purchase_Contract_Line_Item__c> clonePurchaseContractLineItems(
        Map<Id, Id> oldNewPurchaseContractIdMap,
        List<ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractLineItemsToClone
    ) {
        
        final List<ASI_CRM_Purchase_Contract_Line_Item__c> newPurchaseContractLineItems =
            new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
        
        for (ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem : purchaseContractLineItemsToClone) {
            
            final ASI_CRM_Purchase_Contract_Line_Item__c newPurchaseContractLineItem =
                purchaseContractLineItem.clone(false, true, false, false);
            
            newPurchaseContractLineItem.ASI_CRM_Purchase_Contract__c = oldNewPurchaseContractIdMap.get(
                newPurchaseContractLineItem.ASI_CRM_Purchase_Contract__c
            );
            newPurchaseContractLineItem.ASI_CRM_Remarks__c = null;
            System.debug('ASI_CRM_JP_Current_Direct_Supporting__c:::' + purchaseContractLineItem.ASI_CRM_JP_Current_Direct_Supporting__c);
            //			if (purchaseContractLineItem.ASI_CRM_JP_Current_Direct_Supporting__c == null) {
            //				newPurchaseContractLineItem.ASI_CRM_JP_Current_Direct_Supporting__c = null;
            //				newPurchaseContractLineItem.ASI_CRM_JP_Current_Direct_Supporting__c = 0;
            //			}
            newPurchaseContractLineItems.add(newPurchaseContractLineItem);
        }
        
        try {
            Database.insert(newPurchaseContractLineItems, false);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new PurchaseContractImportException(e.getMessage());
        }
        
        return newPurchaseContractLineItems;
    }
    
    public static Boolean isUserSalesAdmin(User u) {
        if (u == null) return false;
        
        return SALES_STAFF_NO.equals(u.ASI_MFM_CN_Staff_No__c) ? true : false;
    }
    
    @testVisible
    private static Double getDoubleValue(String value) {
        try {
            return Double.valueOf(value);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
        }
        return null;
    }
    
    public static String createBatchId() {
        return UserInfo.getUserId() + '-' + DateTime.now().getTime();
    }
    
    public static String getRowDetail(Integer rowIndex) {
        return 'Row ' + rowIndex;
    }
    
    public static List<ASI_CRM_Purchase_Contract__c> clonePurchaseContracts(
        List<ASI_CRM_Purchase_Contract__c> purchaseContractsToClone,
        String batchId
    ) {
        
        final List<ASI_CRM_Purchase_Contract__c> newPurchaseContracts = new List<ASI_CRM_Purchase_Contract__c>();
        
        for (ASI_CRM_Purchase_Contract__c purchaseContract : purchaseContractsToClone) {
            newPurchaseContracts.add(clonePurchaseContract(batchId, purchaseContract));
        }
        
        try {
            Database.insert(newPurchaseContracts, true);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new PurchaseContractImportException(e.getMessage());
        }
        return newPurchaseContracts;
    }
    
    public static Map<Id, Set<Id>> getPurchaseContractIdItemsIdSetMap(Set<Id> purchaseContractLineItemIds) {
        
        final Set<String> excludedRecordTypeApiNames = new Set<String>();
        excludedRecordTypeApiNames.add(ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_SPTD_Contract.name());
        excludedRecordTypeApiNames.add(
            ASI_CRM_RecordType.ASI_CRM_Purchase_Contract.ASI_CRM_JP_SPTD_Contract_Read_Only.name());
        
        final Map<Id, Set<Id>> purchaseContractIdItemsIdSetMap = new Map<Id, Set<Id>>();
        for (
            ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem
            :
            [
                SELECT Id, RecordType.Name, ASI_CRM_Purchase_Contract__c
                FROM ASI_CRM_Purchase_Contract_Line_Item__c
                WHERE Id IN :purchaseContractLineItemIds
                AND ASI_CRM_Purchase_Contract__r.RecordType.DeveloperName NOT IN :excludedRecordTypeApiNames
            ]) {
                final Id purchaseContractId = purchaseContractLineItem.ASI_CRM_Purchase_Contract__c;
                
                if (purchaseContractIdItemsIdSetMap.get(purchaseContractId) == null) {
                    purchaseContractIdItemsIdSetMap.put(purchaseContractId, new Set<Id>());
                }
                
                purchaseContractIdItemsIdSetMap.get(purchaseContractId).add(purchaseContractLineItem.Id);
            }
        
        return purchaseContractIdItemsIdSetMap;
    }
    
    public static Set<String> getItemGroupCodeFromName(Set<String> itemGroupNames) {
        final Set<String> itemGroupCodes = new Set<String>();
        
        for (String itemGroupName : itemGroupNames) {
            
            if (String.isBlank(itemGroupName)) continue;
            
            final List<String> subStrings = itemGroupName.split('-');
            
            if (subStrings.isEmpty()) continue;
            
            itemGroupCodes.add(subStrings.get(subStrings.size() - 1));
        }
        
        return itemGroupCodes;
    }
    
    @testVisible
    private static void printReportParameters(Reports.ReportMetadata reportMetaData) {
        for (Integer counter = 0; counter < reportMetaData.getReportFilters().size(); counter++) {
            System.debug(reportMetaData.getReportFilters().get(counter).getColumn() + ' ' +
                         reportMetaData.getReportFilters().get(counter).getOperator() + ' ' +
                         reportMetaData.getReportFilters().get(counter).getValue());
        }
    }
    
    @testVisible
    private static Set<Id> filterPurchaseContractItemsByValidRecordTypes(Set<Id> purchaseContractLineItemIds) {
        
        final Map<Id, ASI_CRM_Purchase_Contract_Line_Item__c> purchaseContractIdObjectMap =
            new Map<Id, ASI_CRM_Purchase_Contract_Line_Item__c> ([
                SELECT Id
                FROM ASI_CRM_Purchase_Contract_Line_Item__c
                WHERE Id IN :purchaseContractLineItemIds
                AND ASI_CRM_Purchase_Contract__r.RecordType.DeveloperName NOT IN :getPurchaseContractRecordTypesToExclude()
            ]);
        
        return purchaseContractIdObjectMap.keySet();
    }
    
    @testVisible
    private static ASI_CRM_Purchase_Contract__c clonePurchaseContract(
        String batchId,
        ASI_CRM_Purchase_Contract__c purchaseContract) {
            
            if (purchaseContract == null) return null;
            
            final ASI_CRM_Purchase_Contract__c newPurchaseContract = purchaseContract.clone(
                false, true, false, false
            );
            
            ASI_CRM_JP_UtilityService.clearApprovers(newPurchaseContract);
            
            final Date startDate = newPurchaseContract.ASI_CRM_Start_Date__c;
            final Date endDate = newPurchaseContract.ASI_CRM_End_Date__c;
            
            newPurchaseContract.ASI_CRM_Batch_ID__c = batchId;
            newPurchaseContract.ASI_CRM_Status__c = PURCHASE_CONTRACT_STATUS_DRAFT;
            newPurchaseContract.ASI_CRM_Application_Date__c = Date.today();
            newPurchaseContract.ASI_CRM_Start_Date__c = ASI_CRM_JP_UtilityService.getDateBasedOnFiscalYear(startDate, endDate, false);
            newPurchaseContract.ASI_CRM_End_Date__c = ASI_CRM_JP_UtilityService.getDateBasedOnFiscalYear(startDate, endDate, true);
            newPurchaseContract.ASI_CRM_Remarks__c = '';
            newPurchaseContract.ASI_CRM_Purchase_Contract_External_ID__c = null;
            newPurchaseContract.ASI_CRM_Clone_Id__c = null;
            
            return newPurchaseContract;
        }
    
    public static Integer getFiscalYear(Date currentDate, Date dateForMonth) {
        
        if (currentDate == null || dateForMonth == null) return null;
        
        final Date today = Date.newInstance(currentDate.year(), dateForMonth.month(), dateForMonth.day());
        
        if (today.month() <= 6) {
            return today.addYears(-1).year();
        }
        
        if (today.month() > 6) {
            return today.year();
        }
        
        return null;
    }
    
    public static Date updateDateBasedOnFiscalYear(Date baseDate, Integer fiscalYear) {
        if (baseDate == null) return null;
        
        return Date.newInstance(fiscalYear, baseDate.month(), baseDate.day());
    }
    
    public class ReportParameters {
        public String itemGroupName{
            get; set;
        }
        public String shipToName {
            get; set;
        }
        public Date startDate{
            get; set;
        }
        public Date endToDate{
            get; set;
        }
        public Date endDate{
            get; set;
        }
        public String recordTypeName{
            get; set;
        }
        public String salesGroup{
            get; set;
        }
        public String status{
            get; set;
        }
        public Boolean isEffective {
            get; set;
        }
        public String ownerName{
            get; set;
        }
        
        public ReportParameters() {}
    }
}