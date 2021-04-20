/**************************************************************************************************
 * Name: ASI_CTY_CN_Vendor_PRLine_TriggerClass
 * Object: ASI_MFM_Purchase_Request_Line__c
 * Purpose: 1、Generate PO when PR line is approved.
 * Author:  (Jack Yuan)
 * Create Date: 2020-11-1
 * Modify History:
 * 2020-11-1    Create this class
 * 2020-12-17   By HUJINCHAO-BLS Add po posm city, province, sir emails and operation emails
 * 2020-12-18   By HUJINCHAO-BLS Update supplier email of the Po 
 * 2020-12-24   By HUJINCHAO-BLS Update po budget owner and po owner
 **************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_PRLine_TriggerClass {

    private Static Final Id G_RTID_PO = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');
    private Static Final Id G_RTID_POLINE = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item');
    private Static Final Id G_RTID_POSMLINE = Global_RecordTypeCache.getRtId('ASI_MFM_PO_POSM_Line__cASI_MFM_CN_PO_POSM_Line');
    private Static Final Id G_RTID_QUOTATION = Global_RecordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Quotation');


    public static void afterUpdateMethod(List<ASI_MFM_Purchase_Request_Line__c> trigger_new, Map<Id, ASI_MFM_Purchase_Request_Line__c> trigger_oldMap) {
        autoGeneratePO(trigger_new, trigger_oldMap);
    }
    public static void autoGeneratePO(List<ASI_MFM_Purchase_Request_Line__c> trigger_new, Map<Id, ASI_MFM_Purchase_Request_Line__c> trigger_oldMap){
        Set<Id> approvedIdSet = new Set<Id>();
        for (ASI_MFM_Purchase_Request_Line__c PRline : trigger_new) {
            if (PRline.ASI_CTY_CN_Vendor_Status__c == 'Approved' && trigger_oldMap.get(PRline.Id).ASI_CTY_CN_Vendor_Status__c != 'Approved') {
                approvedIdSet.add(PRline.ASI_CTY_CN_Vendor_Merge_Quotation__c);
            }
        }
        Set<Id> executeIds = new Set<Id>();
        for (ASI_CRM_Quotation__c mergeQ : [SELECT Id, (SELECT ASI_CTY_CN_Purchase_Request_Line__c, 
                                                                  ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Status__c 
                                                           FROM Quotations_quotation__r) 
                                               FROM ASI_CRM_Quotation__c 
                                               WHERE Id IN :approvedIdSet]) {
            Boolean isApproved = true;
            Set<Id> approvedIds = new Set<Id>();
            for (ASI_CRM_Quotation__c subQ : mergeQ.Quotations_quotation__r) {
                if (subQ.ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Status__c != 'Approved') {
                    isApproved = false;
                    break;
                }
                approvedIds.add(subQ.ASI_CTY_CN_Purchase_Request_Line__c);
            }
            if (isApproved) executeIds.addAll(approvedIds);
        }

        System.debug(LoggingLevel.INFO, '*** executeIds: ' + executeIds);
        if (executeIds.isEmpty()) return;

        List<ASI_MFM_Purchase_Request_Line__c> PRLineList = [SELECT ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__c,
                                                                    ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.Name,
                                                                    ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c,
                                                                    ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__c,
                                                                    ASI_CTY_CN_Vendor_Supplier__r.ASI_LUX_Email_Business__c,
                                                                    ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_1__c,
                                                                    ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_2__c,
                                                                    ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_3__c,
                                                                    ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_4__c,
                                                                    ASI_CTY_CN_Vendor_Supplier__r.Phone,
                                                                    ASI_CTY_CN_Vendor_Supplier__r.Fax,
                                                                    ASI_CTY_CN_Vendor_Supplier__c,
                                                                    ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Payment_Terms__c,
                                                                    ASI_CTY_CN_Vendor_Item_Group_Code__r.Name,
                                                                    ASI_CTY_CN_Vendor_Approval_MKT_Manage__c,
                                                                    ASI_CTY_CN_Vendor_Buyer__c,
                                                                    ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Bu__c,
                                                                    ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Responsible_by__c,
                                                                    ASI_MFM_Purchase_Request__r.OwnerId,
                                                                    ASI_MFM_Purchase_Request__r.CreatedById,
                                                                    ASI_CTY_CN_Vendor_Total_Price__c,
                                                                    ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Subchannel__c,
                                                                    ASI_CTY_CN_Vendor_Sample_Price__c,
                                                                    ASI_CTY_CN_Vendor_Model_Price__c,
                                                                    ASI_CTY_CN_Vendor_Approval_Buyer__c,
                                                                    ASI_CTY_CN_Vendor_Merge_Quotation__c,
                                                                    ASI_CTY_CN_Vendor_Select_Quotation__c,
                                                                    ASI_CTY_CN_Vendor_Select_Quotation__r.ASI_CTY_CN_Vendor_DeadLine__c,
                                                                    ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_PP_Category__c,
                                                                    (SELECT ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.CreatedById,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Responsible_by__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__c,
                                                                            ASI_CTY_CN_Vendor_Supplier__r.ASI_LUX_Email_Business__c,
                                                                            ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_1__c,
                                                                            ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_2__c,
                                                                            ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_3__c,
                                                                            ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_4__c,
                                                                            ASI_CTY_CN_Vendor_Supplier__r.Phone,
                                                                            ASI_CTY_CN_Vendor_Supplier__r.Fax,
                                                                            ASI_CTY_CN_Vendor_Supplier__c,
                                                                            ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Payment_Terms__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.Name,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Approval_MKT_Manage__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Approval_Buyer__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Bu__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Price__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Subchannel__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.OwnerId,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_PP_Category__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.Name,
                                                                            ASI_CTY_CN_Vendor_Quotation__c,
                                                                            ASI_CTY_CN_Vendor_Sample__c,
                                                                            ASI_CTY_CN_Vendor_Model__c,
                                                                            ASI_CTY_CN_Purchase_Request_Line__c,
                                                                            ASI_CTY_CN_Vendor_Result_Status__c,
                                                                            ASI_CTY_CN_Vendor_IsConfirmed__c,
                                                                            ASI_CTY_CN_Vendor_DeadLine__c
                                                                      FROM quotations__r
                                                                      WHERE RecordTypeId = :G_RTID_QUOTATION)
                                                             FROM ASI_MFM_Purchase_Request_Line__c
                                                             WHERE Id IN :executeIds];

        List<ASI_CRM_Quotation__c> winBidQutations = new List<ASI_CRM_Quotation__c>();
        List<ASI_CRM_Quotation__c> failBidQuotations = new List<ASI_CRM_Quotation__c>();
        List<ASI_CRM_Quotation__c> otherQuotations = new List<ASI_CRM_Quotation__c>();
        Set<Id> failMergeQIds = new Set<Id>();
        for (ASI_MFM_Purchase_Request_Line__c PRline : PRLineList) {
            if (PRline.quotations__r != null) {
                for (ASI_CRM_Quotation__c quotation : PRline.quotations__r) {
                    if (quotation.ASI_CTY_CN_Vendor_Result_Status__c == 'Win-Bid') {
                        winBidQutations.add(quotation);
                    } else if (quotation.ASI_CTY_CN_Vendor_Result_Status__c != 'Win-Bid' 
                        && quotation.ASI_CTY_CN_Vendor_IsConfirmed__c == true
                        && (quotation.ASI_CTY_CN_Vendor_Sample__c > 0 || quotation.ASI_CTY_CN_Vendor_Model__c > 0)) {
                        failBidQuotations.add(quotation);
                    } else {
                        quotation.ASI_CTY_CN_Vendor_Result_Status__c = 'Fail-Bid';
                        otherQuotations.add(quotation);
                        failMergeQIds.add(quotation.ASI_CTY_CN_Vendor_Quotation__c);
                    }
                    
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** winBidQutations: ' + winBidQutations);
        System.debug(LoggingLevel.INFO, '*** failBidQuotations: ' + failBidQuotations);
        List<ASI_CRM_Quotation__c> updateQuotations = new List<ASI_CRM_Quotation__c>();
        Set<Id> poIds = new Set<Id>();
        if (!PRLineList.isEmpty()) {
            List<ASI_MFM_PO__c> POList = PRLineGeneratePO(PRLineList);
            Map<Id, Id> quotationPOIdMap = new Map<Id, Id>();
            for (ASI_MFM_PO__c po : POList) {
                quotationPOIdMap.put(po.ASI_CTY_CN_Vendor_Quotation__c, po.Id);
                poIds.add(po.Id);
            }
            if (!winBidQutations.isEmpty()) {
                for (ASI_CRM_Quotation__c quotation : winBidQutations) {
                    quotation.ASI_CTY_CN_Vendor_PO__c = quotationPOIdMap.containsKey(quotation.Id) ? quotationPOIdMap.get(quotation.Id) : null;
                    updateQuotations.add(quotation);
                }
            }
        }
        if (!failBidQuotations.isEmpty()) {
            List<ASI_MFM_PO__c> POList = quotationGeneratePO(failBidQuotations);
            Map<Id, Id> mergeQPOIdMap = new Map<Id, Id>();
            for (ASI_MFM_PO__c po : POList) {
                mergeQPOIdMap.put(po.ASI_CTY_CN_Vendor_Quotation__c, po.Id);
                poIds.add(po.Id);
            }
            Set<Id> mergeQuotationIds = new Set<Id>();
            for (ASI_CRM_Quotation__c quotation : failBidQuotations) {
                quotation.ASI_CTY_CN_Vendor_Result_Status__c = 'Sample-Bid';
                quotation.ASI_CTY_CN_Vendor_PO__c = mergeQPOIdMap.containsKey(quotation.ASI_CTY_CN_Vendor_Quotation__c) ? mergeQPOIdMap.get(quotation.ASI_CTY_CN_Vendor_Quotation__c) : null;
                mergeQuotationIds.add(quotation.ASI_CTY_CN_Vendor_Quotation__c);
                updateQuotations.add(quotation);
            }
            for (Id mergeId : mergeQuotationIds) {
                if (failMergeQIds.contains(mergeId)) {
                    failMergeQIds.remove(mergeId);
                }
                ASI_CRM_Quotation__c mergeQ = new ASI_CRM_Quotation__c(Id = mergeId, ASI_CTY_CN_Vendor_Result_Status__c = 'Sample-Bid');
                mergeQ.ASI_CTY_CN_Vendor_PO__c = mergeQPOIdMap.containsKey(mergeQ.Id) ? mergeQPOIdMap.get(mergeQ.Id) : null;
                updateQuotations.add(mergeQ);
            }
        }
        for (Id mergeId : failMergeQIds) {
            ASI_CRM_Quotation__c mergeQ = new ASI_CRM_Quotation__c(Id = mergeId, ASI_CTY_CN_Vendor_Result_Status__c = 'Fail-Bid');
            updateQuotations.add(mergeQ);
        }
        updateQuotations.addAll(otherQuotations);
        if (!updateQuotations.isEmpty()) {
            update updateQuotations;
        }
        List<ASI_MFM_Purchase_Request_Line__c> updatePRlines = new List<ASI_MFM_Purchase_Request_Line__c>();
        for (Id PRId : executeIds) {
            ASI_MFM_Purchase_Request_Line__c PRLine = new ASI_MFM_Purchase_Request_Line__c(Id = PRId);
            PRline.ASI_CTY_CN_Vendor_Status__c = 'Generate PO';
            updatePRlines.add(PRLine);
        }
        update updatePRlines;
        
        if (poIds.size() > 0) {
            updatePOFinal(poIds);//for future
        }
    }

    @future
    public static void updatePOFinal(Set<Id> poIds){
        List<ASI_MFM_PO__c> updatePOList = new List<ASI_MFM_PO__c>();
        for (Id poId : poIds) {
            updatePOList.add(new ASI_MFM_PO__c(Id = poId, ASI_MFM_Status__c= 'Final'));
        }
        update updatePOList;
    }

    public static List<ASI_MFM_PO__c> PRLineGeneratePO(List<ASI_MFM_Purchase_Request_Line__c> PRLineList) {
        List<ASI_MFM_PO__c> POList = new List<ASI_MFM_PO__c>();
        Date startDate = Date.today();
        Date endDate = Date.today();
        List<String> buList = new List<String>();
        Set<String> fiscalYears = new Set<String>();
        for (ASI_MFM_Purchase_Request_Line__c PRline : PRLineList) {
            buList.add(PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Bu__c);
            System.debug(LoggingLevel.INFO, '*** : ' + PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c);
            fiscalYears.add(PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c);
        }
        System.debug(LoggingLevel.INFO, '*** fiscalYears: ' + fiscalYears);
        // 查询prefix
        List<ASI_MFM_Prefix__c> prefixList = [SELECT Id,Name,ASI_MFM_Fiscal_year__c FROM ASI_MFM_Prefix__c 
                                            WHERE recordtype.developername = 'ASI_MFM_CN_Prefix' 
                                            AND ASI_MFM_Module__c = 'PO' 
                                            AND (Name LIKE '%22%' OR Name LIKE '%25%')
                                            AND ASI_MFM_Fiscal_year__c IN :fiscalYears];
        System.debug(LoggingLevel.INFO, '*** prefixList: ' + prefixList);
        Map<String, ASI_MFM_Prefix__c> prefixMap = new  Map<String, ASI_MFM_Prefix__c>();
        for (ASI_MFM_Prefix__c prefix : prefixList) {
            String preKey = '';
            if (prefix.Name.startsWith('22')) {
                preKey = '22' + prefix.ASI_MFM_Fiscal_year__c;
            } else if (prefix.Name.startsWith('25')) {
                preKey = '25' + prefix.ASI_MFM_Fiscal_year__c;
            }
            prefixMap.put(preKey, prefix);
        }

        Map<String, String> buMap = new Map<String, String>();
        for (ASI_MFM_BU__c bu : [SELECT Id, Name, ASI_MFM_BU_Code__c FROM ASI_MFM_BU__c WHERE ASI_MFM_CN_Country__c = 'CN' AND ASI_MFM_BU_Code__c IN :buList]) {
            buMap.put(bu.ASI_MFM_BU_Code__c, bu.Id);
        }

        // By HUJINCHAO-BLS 2020-12-18 get supplier contact emial according to supplier ids Start
        Set<Id> supplierIds = new Set<Id>();
        Map<Id, String> supplierContactEmail = new Map<Id, String>();
        for (ASI_MFM_Purchase_Request_Line__c PRline : PRLineList) {
            supplierIds.add(PRline.ASI_CTY_CN_Vendor_Supplier__c);
        }

        if (supplierIds.size() > 0) {
            for (User u : [SELECT Id, Name, Email, Contact.AccountId FROM User WHERE User.Profile.Name = 'ASI_CTY_PRCVendor_CN_User' AND Contact.AccountId In :supplierIds]) {
                supplierContactEmail.put(u.Contact.AccountId, u.Email);
            }
        }
        // By HUJINCHAO-BLS 2020-12-18 get supplier contact emial according to supplier ids End

        for (ASI_MFM_Purchase_Request_Line__c PRline : PRLineList) {
            System.debug(LoggingLevel.INFO, '*** JSON.serialize(PRline): ' + JSON.serialize(PRline));
            ASI_MFM_PO__c po = new ASI_MFM_PO__c();
            po.RecordTypeId = G_RTID_PO;
            po.ASI_CTY_CN_Vendor_Purchase_Request_Line__c = PRline.Id;
            po.ASI_MFM_Plan__c = PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__c;
            po.ASI_MFM_From_eMarket__c = true;
            po.ASI_MFM_PO_Type__c = 'eMarket';
            po.ASI_MFM_Status__c = 'Draft';
            po.ASI_MFM_GL_Date__c = Date.today();
            if(PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c != null){ 
                String fiscalYear = PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c;
                startDate = Date.newinstance((2000+integer.valueof(fiscalYear.substring(2,4))),7,1);
                endDate = Date.newinstance((2000+integer.valueof(fiscalYear.substring(4,6))),6,30);
            }
            po.ASI_CTY_CN_Vendor_Sample_Price__c = PRline.ASI_CTY_CN_Vendor_Sample_Price__c;
            po.ASI_CTY_CN_Vendor_Model_Price__c = PRline.ASI_CTY_CN_Vendor_Model_Price__c;
            po.ASI_MFM_PO_Start_Date__c = startDate;
            po.ASI_MFM_PO_End_Date__c = endDate;
            String preKey = '';
            if (PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.Name.startsWith('CNB')) {
                preKey = '22' + PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c;
            } else{
                preKey = '25' + PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c;
            }
            System.debug(LoggingLevel.INFO, '*** preKey: ' + preKey);
            System.debug(LoggingLevel.INFO, '*** prefixMap: ' + prefixMap);
            po.ASI_MFM_Prefix__c = prefixMap.containsKey(preKey) ? prefixMap.get(preKey).Id : null;
            
            po.ASI_MFM_Supplier_Name__c = PRline.ASI_CTY_CN_Vendor_Supplier__c;
            // By HUJINCHAO-BLS 2020-12-18 If the supplier does not have an email address, the email of the contact user under the supplier will be assigned to the supplier email of the Po Start
                if (PRline.ASI_CTY_CN_Vendor_Supplier__r.ASI_LUX_Email_Business__c != null) {
                    po.ASI_MFM_Supplier_Email__c = PRline.ASI_CTY_CN_Vendor_Supplier__r.ASI_LUX_Email_Business__c;
                } else {
                    if (supplierContactEmail.containsKey(PRline.ASI_CTY_CN_Vendor_Supplier__c)) {
                        po.ASI_MFM_Supplier_Email__c = supplierContactEmail.get(PRline.ASI_CTY_CN_Vendor_Supplier__c);
                    }
                }
            // By HUJINCHAO-BLS 2020-12-18 If the supplier does not have an email address, the email of the contact user under the supplier will be assigned to the supplier email of the Po End

            po.ASI_MFM_Supplier_Address_Line_1__c = PRline.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_1__c;
            po.ASI_MFM_Supplier_Address_Line_2__c = PRline.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_2__c;
            po.ASI_MFM_Supplier_Address_Line_3__c = PRline.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_3__c;
            po.ASI_MFM_Supplier_Address_Line_4__c = PRline.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_4__c;
            po.ASI_MFM_Supplier_Fax_Number__c = PRline.ASI_CTY_CN_Vendor_Supplier__r.Fax;
            po.ASI_MFM_Supplier_Phone_Number__c = PRline.ASI_CTY_CN_Vendor_Supplier__r.Phone;
            po.ASI_MFM_Payment_Terms__c = PRline.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Payment_Terms__c;
            po.ASI_CTY_CN_Vendor_Quotation__c = PRline.ASI_CTY_CN_Vendor_Select_Quotation__c;

            po.ASI_MFM_Remarks__c = PRline.ASI_CTY_CN_Vendor_Item_Group_Code__r.Name;
            po.ASI_MFM_PO_Raised_Date__c = Date.today();
            po.ASI_MFM_PO_Final_Date__c = Date.today();

            // By HUJINCHAO-BLS 2020-12-24 update po budget owner to PR budget owner, po owner to PR create user start
            po.ASI_MFM_Budget_Owner__c = PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Responsible_by__c;
            po.OwnerId = PRline.ASI_MFM_Purchase_Request__r.CreatedById;
            // By HUJINCHAO-BLS 2020-12-24 update po budget owner to PR budget owner, po owner to PR create user end

            po.ASI_MFM_eMarket_Buyer__c = PRline.ASI_CTY_CN_Vendor_Approval_Buyer__c;
            po.ASI_MFM_CN_BU_Picklist__c = PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Bu__c;
            po.ASI_MFM_BU_Code__c = buMap.containsKey(po.ASI_MFM_CN_BU_Picklist__c) ? buMap.get(po.ASI_MFM_CN_BU_Picklist__c) : null;
            po.ASI_MFM_PO_Channel__c = PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Subchannel__c;
            po.ASI_MFM_Currency__c = 'RMB';
            po.ASI_MFM_Exchange_Rate__c = 1;
            System.debug(LoggingLevel.INFO, '*** JSON.serialize(po): ' + JSON.serialize(po));
            po.ASI_CTY_CN_Vendor_Is_Generated_By_PR__c = true;
            po.ASI_MFM_PO_PP_Category__c = PRline.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_PP_Category__c;
            Integer deadLine = PRline.ASI_CTY_CN_Vendor_Select_Quotation__r.ASI_CTY_CN_Vendor_DeadLine__c != null ? Integer.valueOf(PRline.ASI_CTY_CN_Vendor_Select_Quotation__r.ASI_CTY_CN_Vendor_DeadLine__c) : null;
            po.ASI_CTY_CN_Vendor_Delivery_Date__c = deadLine == null ? null : Date.today().addDays(deadLine);
            POList.add(po);
        }

        if (!POList.isEmpty()) {
            insert POList;
            // manualShareRead(POList);
        }
        
        CreateLineDetails(POList);
        return POList;
    }

   //  public static void manualShareRead(List<ASI_MFM_PO__c> POList){
   //      List<ASI_MFM_PO__Share> poshrs = new List<ASI_MFM_PO__Share>();
   //      for (ASI_MFM_PO__c po : POList) {
   //          // Create new sharing object for po
   //          ASI_MFM_PO__Share poShr  = new ASI_MFM_PO__Share();
   //          poShr.ParentId = po.Id;
   //          poShr.UserOrGroupId = po.ASI_MFM_eMarket_Buyer__c;
   //          poShr.AccessLevel = 'Read';
   //          poShr.RowCause = Schema.ASI_MFM_PO__Share.RowCause.Manual;
   //          poshrs.add(poShr);
   //      }
   //      insert poshrs;
   // }

    public static List<ASI_MFM_PO__c> quotationGeneratePO(List<ASI_CRM_Quotation__c> quotations){

        Date startDate = Date.today();
        Date endDate = Date.today();
        List<String> buList = new List<String>();
        Set<String> fiscalYears = new Set<String>();
         for (ASI_CRM_Quotation__c quotation : quotations) {
            buList.add(quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Bu__c);
            fiscalYears.add(quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c);
        }
        
        System.debug(LoggingLevel.INFO, '*** fiscalYears: ' + fiscalYears);
        // 查询prefix
        List<ASI_MFM_Prefix__c> prefixList = [SELECT Id,Name,ASI_MFM_Fiscal_year__c FROM ASI_MFM_Prefix__c 
                                            WHERE recordtype.developername = 'ASI_MFM_CN_Prefix' 
                                            AND ASI_MFM_Module__c = 'PO' 
                                            AND (Name LIKE '%22%' OR Name LIKE '%25%')
                                            AND ASI_MFM_Fiscal_year__c IN :fiscalYears];
        System.debug(LoggingLevel.INFO, '*** prefixList: ' + prefixList);
        Map<String, ASI_MFM_Prefix__c> prefixMap = new  Map<String, ASI_MFM_Prefix__c>();
        for (ASI_MFM_Prefix__c prefix : prefixList) {
            String preKey = '';
            if (prefix.Name.startsWith('22')) {
                preKey = '22' + prefix.ASI_MFM_Fiscal_year__c;
            } else if (prefix.Name.startsWith('25')) {
                preKey = '25' + prefix.ASI_MFM_Fiscal_year__c;
            }
            prefixMap.put(preKey, prefix);
        }

       
        Map<String, String> buMap = new Map<String, String>();
        for (ASI_MFM_BU__c bu : [SELECT Id, Name, ASI_MFM_BU_Code__c FROM ASI_MFM_BU__c WHERE ASI_MFM_CN_Country__c = 'CN' AND ASI_MFM_BU_Code__c IN :buList]) {
            buMap.put(bu.ASI_MFM_BU_Code__c, bu.Id);
        }
        Map<Id, ASI_MFM_PO__c> quoteIdPOMap = new Map<Id, ASI_MFM_PO__c>();

        // By HUJINCHAO-BLS 2020-12-18 get supplier contact emial according to supplier ids Start
        Set<Id> supplierIds = new Set<Id>();
        Map<Id, String> supplierContactEmail = new Map<Id, String>();
        for (ASI_CRM_Quotation__c quotation : quotations) { 
            supplierIds.add(quotation.ASI_CTY_CN_Vendor_Supplier__c);
        }
        System.debug(LoggingLevel.INFO, '*** supplierIds: ' + supplierIds);

        if (supplierIds.size() > 0) {
            for (User u : [SELECT Id, Name, Email, Contact.AccountId FROM User WHERE User.Profile.Name = 'ASI_CTY_PRCVendor_CN_User' AND Contact.AccountId In :supplierIds]) {
                supplierContactEmail.put(u.Contact.AccountId, u.Email);
            }
        }
        System.debug(LoggingLevel.INFO, '*** supplierContactEmail: ' + supplierContactEmail);
        // By HUJINCHAO-BLS 2020-12-18 get supplier contact emial according to supplier ids End

        for (ASI_CRM_Quotation__c quotation : quotations) {
            if (quoteIdPOMap.containsKey(quotation.ASI_CTY_CN_Vendor_Quotation__c)) {
                ASI_MFM_PO__c po = quoteIdPOMap.get(quotation.ASI_CTY_CN_Vendor_Quotation__c);
                po.ASI_CTY_CN_Vendor_Sample_Price__c += quotation.ASI_CTY_CN_Vendor_Sample__c;
                po.ASI_CTY_CN_Vendor_Model_Price__c += quotation.ASI_CTY_CN_Vendor_Model__c;
                
            } else {
                ASI_MFM_PO__c po = new ASI_MFM_PO__c();
                po.RecordTypeId = G_RTID_PO;
                po.ASI_CTY_CN_Vendor_Purchase_Request_Line__c = quotation.ASI_CTY_CN_Purchase_Request_Line__c;
                po.ASI_CTY_CN_Vendor_Quotation__c = quotation.ASI_CTY_CN_Vendor_Quotation__c;
                po.ASI_MFM_Plan__c = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__c;
                po.ASI_MFM_From_eMarket__c = true;
                po.ASI_MFM_PO_Type__c = 'eMarket';
                po.ASI_MFM_Status__c = 'Draft';
                po.ASI_MFM_GL_Date__c = Date.today();
                if(quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c != null){ 
                    String fiscalYear = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c;
                    startDate = Date.newinstance((2000+integer.valueof(fiscalYear.substring(2,4))),7,1);
                    endDate = Date.newinstance((2000+integer.valueof(fiscalYear.substring(4,6))),6,30);
                }
                po.ASI_MFM_PO_Start_Date__c = startDate;
                po.ASI_MFM_PO_End_Date__c = endDate;
                 String preKey = '';
                if (quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.Name.startsWith('CNB')) {
                    preKey = '22' + quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c;
                } else
                {
                    preKey = '25' + quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c;
                }
                po.ASI_MFM_Prefix__c = prefixMap.containsKey(preKey) ? prefixMap.get(preKey).Id : null;
                po.ASI_CTY_CN_Vendor_Sample_Price__c = quotation.ASI_CTY_CN_Vendor_Sample__c;
                po.ASI_CTY_CN_Vendor_Model_Price__c = quotation.ASI_CTY_CN_Vendor_Model__c;

                po.ASI_MFM_Supplier_Name__c = quotation.ASI_CTY_CN_Vendor_Supplier__c;

                // By HUJINCHAO-BLS 2020-12-18 If the supplier does not have an email address, the email of the contact user under the supplier will be assigned to the supplier email of the Po Start
                if (quotation.ASI_CTY_CN_Vendor_Supplier__r.ASI_LUX_Email_Business__c != null) {
                    po.ASI_MFM_Supplier_Email__c = quotation.ASI_CTY_CN_Vendor_Supplier__r.ASI_LUX_Email_Business__c;
                } else {
                    if (supplierContactEmail.containsKey(quotation.ASI_CTY_CN_Vendor_Supplier__c)) {
                        po.ASI_MFM_Supplier_Email__c = supplierContactEmail.get(quotation.ASI_CTY_CN_Vendor_Supplier__c);
                    }
                }
                // By HUJINCHAO-BLS 2020-12-18 If the supplier does not have an email address, the email of the contact user under the supplier will be assigned to the supplier email of the Po End

                po.ASI_MFM_Supplier_Address_Line_1__c = quotation.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_1__c;
                po.ASI_MFM_Supplier_Address_Line_2__c = quotation.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_2__c;
                po.ASI_MFM_Supplier_Address_Line_3__c = quotation.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_3__c;
                po.ASI_MFM_Supplier_Address_Line_4__c = quotation.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Address_Line_4__c;
                po.ASI_MFM_Supplier_Fax_Number__c = quotation.ASI_CTY_CN_Vendor_Supplier__r.Fax;
                po.ASI_MFM_Supplier_Phone_Number__c = quotation.ASI_CTY_CN_Vendor_Supplier__r.Phone;
                po.ASI_MFM_Payment_Terms__c = quotation.ASI_CTY_CN_Vendor_Supplier__r.ASI_MFM_Payment_Terms__c;

                po.ASI_MFM_Remarks__c = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.Name;
                po.ASI_MFM_PO_Raised_Date__c = Date.today();
                po.ASI_MFM_PO_Final_Date__c = Date.today();

                
                // By HUJINCHAO-BLS 2020-12-24 update po budget owner to PR budget owner, po owner to PR create user start
                po.ASI_MFM_Budget_Owner__c = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Responsible_by__c;
                po.OwnerId = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.CreatedById;
                // By HUJINCHAO-BLS 2020-12-24 update po budget owner to PR budget owner, po owner to PR create user end

                po.ASI_MFM_eMarket_Buyer__c = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Approval_Buyer__c;
                po.ASI_MFM_CN_BU_Picklist__c = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Bu__c;
                po.ASI_MFM_BU_Code__c = buMap.containsKey(po.ASI_MFM_CN_BU_Picklist__c) ? buMap.get(po.ASI_MFM_CN_BU_Picklist__c) : null;
                po.ASI_MFM_PO_Channel__c = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_Subchannel__c;
                po.ASI_MFM_Currency__c = 'RMB';
                po.ASI_MFM_Exchange_Rate__c = 1;
                po.ASI_MFM_PO_PP_Category__c = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_PP_Category__c;
                po.ASI_CTY_CN_Vendor_Is_Generated_By_PR__c = true;
                Integer deadLine = quotation.ASI_CTY_CN_Vendor_DeadLine__c != null ? Integer.valueOf(quotation.ASI_CTY_CN_Vendor_DeadLine__c) : null;
                po.ASI_CTY_CN_Vendor_Delivery_Date__c = deadLine == null ? null : Date.today().addDays(deadLine);
                quoteIdPOMap.put(quotation.ASI_CTY_CN_Vendor_Quotation__c, po);
            }
            
        }

        if (!quoteIdPOMap.values().isEmpty()) {
            insert quoteIdPOMap.values();
            // manualShareRead(quoteIdPOMap.values());
        }
        createdPOLineItems(quoteIdPOMap.values());
        return quoteIdPOMap.values();

    }

    public static void createdPOLineItems(List<ASI_MFM_PO__c> newPOList){
        List<ASI_MFM_PO_Line_Item__c> POLineList = new List<ASI_MFM_PO_Line_Item__c>();
        List<ASI_MFM_PO__c> POList = [SELECT ASI_MFM_BU_Code__c,
                                             ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Item_Group__c,
                                             ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Sub_brand__c,
                                             ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_Alternative_SKU__c,
                                             ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Item_Group__r.Name,
                                             ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_AC_Code__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_SubBrand__c,
                                             ASI_CTY_CN_Vendor_Sample_Price__c,
                                             ASI_CTY_CN_Vendor_Model_Price__c
                                      FROM ASI_MFM_PO__c
                                      WHERE Id IN :newPOList];
        for (ASI_MFM_PO__c po : POList) {

            ASI_MFM_PO_Line_Item__c poLineItem = new ASI_MFM_PO_Line_Item__c();
            poLineItem.RecordTypeId = G_RTID_POLINE;           
            poLineItem.ASI_MFM_From_eMarket__c = true;
            poLineItem.ASI_MFM_G_L_Date__c = Date.today();
            poLineItem.ASI_MFM_BU_Code__c = po.ASI_MFM_BU_Code__c;
            poLineItem.ASI_MFM_A_C_Code__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_AC_Code__c;
            poLineItem.ASI_MFM_PO__c = po.Id;
            poLineItem.ASI_MFM_Sub_brand_Code__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_SubBrand__c;
            poLineItem.ASI_MFM_SKU_Code__c = po.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_Alternative_SKU__c;
            poLineItem.ASI_MFM_List_Item_Description__c = 'Sample & Model fee: ' + po.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Item_Group__r.Name;
            poLineItem.ASI_MFM_Quantity__c = 1;
            poLineItem.ASI_CTY_CN_Vendor_Sample_Fee__c = true;
            poLineItem.ASI_MFM_Unit_Price__c = po.ASI_CTY_CN_Vendor_Sample_Price__c + po.ASI_CTY_CN_Vendor_Model_Price__c;
            poLineItem.ASI_MFM_Item_Group_Code__c = po.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c;
            poLineItem.ASI_MFM_Amount__c = poLineItem.ASI_MFM_Unit_Price__c;
            System.debug(LoggingLevel.INFO, '*** poLineItem: ' + poLineItem);
            POLineList.add(poLineItem);
        }
        if (!POLineList.isEmpty()) {
            insert POLineList;
        }

        
    }

    public static void CreateLineDetails(List<ASI_MFM_PO__c> newPOList){
        List<ASI_MFM_PO_Line_Item__c> POLineList = new List<ASI_MFM_PO_Line_Item__c>();
        List<ASI_MFM_PO_POSM_Line__c> LPOSMLineList = new List<ASI_MFM_PO_POSM_Line__c>();
        Set<Id> PRlineIds = new Set<Id>();
        List<ASI_MFM_PO__c> POList = [SELECT ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_MFM_A_C_Code__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_MFM_Sub_brand__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Freight__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.Name,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Quantity__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Unit_Price__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_SubBrand__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_MFM_Item_Group_Code__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_AC_Code__c,
                                             ASI_MFM_BU_Code__c,
                                             ASI_CTY_CN_Vendor_Sample_Price__c,
                                             ASI_CTY_CN_Vendor_Model_Price__c,
                                             ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_Alternative_SKU__c,
                                             ASI_MFM_Supplier_Email__c,
                                             ASI_MFM_Budget_Owner__c
                                      FROM ASI_MFM_PO__c
                                      WHERE Id IN :newPOList];
        for (ASI_MFM_PO__c po : POList) {
            PRlineIds.add(po.ASI_CTY_CN_Vendor_Purchase_Request_Line__c);
            ASI_MFM_PO_Line_Item__c normalPOline = generatePOLineItem(po);
            POLineList.add(normalPOline);
            if (po.ASI_CTY_CN_Vendor_Sample_Price__c > 0 || po.ASI_CTY_CN_Vendor_Model_Price__c > 0) {
                ASI_MFM_PO_Line_Item__c sampleFeePOline = generatePOLineItem(po);
                sampleFeePOline.ASI_MFM_List_Item_Description__c = 'Sample & Model fee: ' + po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.Name;
                sampleFeePOline.ASI_MFM_Quantity__c = 1;
                sampleFeePOline.ASI_MFM_Unit_Price__c = po.ASI_CTY_CN_Vendor_Sample_Price__c + po.ASI_CTY_CN_Vendor_Model_Price__c;
                sampleFeePOline.ASI_MFM_Amount__c = sampleFeePOline.ASI_MFM_Unit_Price__c;
                sampleFeePOline.ASI_CTY_CN_Vendor_Sample_Fee__c = true;
                POLineList.add(sampleFeePOline);
            }
           
            if (po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Freight__c > 0) {
                ASI_MFM_PO_Line_Item__c deliveryFeePOline = generatePOLineItem(po);
                deliveryFeePOline.ASI_MFM_Quantity__c = 0;
                deliveryFeePOline.ASI_MFM_Unit_Price__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Freight__c;
                deliveryFeePOline.ASI_MFM_Amount__c = deliveryFeePOline.ASI_MFM_Unit_Price__c;
                deliveryFeePOline.ASI_MFM_Delivery_Fee__c = true;
                deliveryFeePOline.ASI_MFM_List_Item_Description__c = 'Delivery fee: ' + po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.Name;
                POLineList.add(deliveryFeePOline);
            }
            
            
        }
        if (!POLineList.isEmpty()) {
            insert POLineList;
        }

        
        List<ASI_MFM_Purchase_Request_Line__c> PRLineList = [SELECT ASI_CTY_CN_Vendor_Item_Group_Code__c, 
                                                                    ASI_CTY_CN_Vendor_Unit_Price__c,
                                                                    ASI_CTY_CN_Vendor_Select_Quotation__c
                                                             FROM ASI_MFM_Purchase_Request_Line__c
                                                             WHERE Id IN :PRlineIds];
        List<ASI_FOC_Warehouse__c> wareList = [SELECT Id FROM ASI_FOC_Warehouse__c WHERE ASI_MFM_Is_Active__c = true 
                                            AND ASI_MFM_Direct_Delivery__c = true 
                                            AND ASI_FOC_Warehouse_Code__c = 'DUMMY'];
        Set<Id> selectQuoteIds = new Set<Id>();
        for (ASI_MFM_Purchase_Request_Line__c PRLine : PRLineList) {
            selectQuoteIds.add(PRLine.ASI_CTY_CN_Vendor_Select_Quotation__c);
        }
        List<ASI_CRM_Quotation__c> quotations = [SELECT ASI_CTY_CN_Purchase_Request_Line__c,
                                                        ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__c,
                                                        ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Unit_Price__c,                                                        
                                                        (SELECT ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Warehouse__c,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Outlet__c,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Contact__r.Name,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Contact__r.MailingCity,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Contact__r.MailingState,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Contact__r.MobilePhone,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Quantity_Required__c,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Delivery_Address__c,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_ContactName__c,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Receipt_Phone__c,
                                                                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_ReceiptOwner__c,
                                                                ASI_CTY_CN_Vendor_Freight__c
                                                         FROM Quotation_Line_Items__r)
                                                FROM ASI_CRM_Quotation__c WHERE Id IN :selectQuoteIds];
        Map<Id, ASI_CRM_Quotation__c> quotationMap = new Map<Id, ASI_CRM_Quotation__c>();
        Map<Id, ASI_FOC_Warehouse__c> warehouseMap = new Map<Id, ASI_FOC_Warehouse__c>();
        Set<Id> warehouseIds = new Set<Id>();
        for (ASI_CRM_Quotation__c quotation : quotations) {
            quotationMap.put(quotation.ASI_CTY_CN_Purchase_Request_Line__c, quotation);

            // By HUJINCHAO-BLS 2020-12-17 get Warehouse ids Start
            List<ASI_CRM_Quotation_Line_Item__c> quoteLineItemList = quotation.Quotation_Line_Items__r;
            if (quoteLineItemList != null && quoteLineItemList.size() > 0) {
                for (ASI_CRM_Quotation_Line_Item__c quoteline : quoteLineItemList) {
                    if (quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Warehouse__c != null) {
                        warehouseIds.add(quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Warehouse__c);
                    }
                }
            }
            if (wareList != null && wareList.size() > 0) {
                warehouseIds.add(wareList.get(0).Id);
            }
            // By HUJINCHAO-BLS 2020-12-17 get Warehouse ids End
        }

        // By HUJINCHAO-BLS 2020-12-17 get Warehouse infos Start
        if (warehouseIds.size() > 0) {
            for (ASI_FOC_Warehouse__c wh : [SELECT Id, Name, ASI_FOC_City__r.Name, ASI_FOC_City__r.ASI_CRM_CN_Province__r.Name,
                            ASI_FOC_SIR_Email_Address_1__c, ASI_FOC_SIR_Email_Address_2__c,
                            ASI_FOC_SIR_Email_Address_3__c, ASI_FOC_SIR_Email_Address_4__c,
                            ASI_FOC_SIR_Email_Address_5__c, ASI_FOC_SIR_Email_Address_6__c,
                            ASI_FOC_SIR_Email_Address_7__c, ASI_FOC_SIR_Email_Address_8__c,
                            ASI_MFM_Operation_Team_Email_1__c, ASI_MFM_Operation_Team_Email_2__c,
                            ASI_MFM_Operation_Team_Email_3__c, ASI_MFM_Operation_Team_Email_4__c,
                            ASI_MFM_Operation_Team_Email_5__c, ASI_MFM_Operation_Team_Email_6__c,
                            ASI_MFM_Operation_Team_Email_7__c, ASI_MFM_Operation_Team_Email_8__c
                            FROM ASI_FOC_Warehouse__c WHERE Id IN :warehouseIds]) {
                warehouseMap.put(wh.Id, wh);
            }
        }
        System.debug(LoggingLevel.INFO, '*** warehouseMap: ' + warehouseMap);
        // By HUJINCHAO-BLS 2020-12-17 get Warehouse infos End

        List<ASI_MFM_Tax_Code__c> taxCodes = [SELECT Id FROM ASI_MFM_Tax_Code__c WHERE Name = 'OTH' AND RecordType.DeveloperName = 'ASI_MFM_CN_Tax_Code'];
        for (ASI_MFM_PO__c po : POList) {
            if (quotationMap.containsKey(po.ASI_CTY_CN_Vendor_Purchase_Request_Line__c)) {
                ASI_CRM_Quotation__c quotation = quotationMap.get(po.ASI_CTY_CN_Vendor_Purchase_Request_Line__c);
                for (ASI_CRM_Quotation_Line_Item__c quoteline : quotation.Quotation_Line_Items__r) {
                    ASI_MFM_PO_POSM_Line__c poPOSMLine = new ASI_MFM_PO_POSM_Line__c();
                    poPOSMLine.RecordTypeId = G_RTID_POSMLINE;
                    poPOSMLine.ASI_MFM_Item_Group__c = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__c;
                    poPOSMLine.ASI_MFM_Quantity__c = quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Quantity_Required__c;
                    poPOSMLine.ASI_MFM_Unit_Price__c = quotation.ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Unit_Price__c;
                    poPOSMLine.ASI_MFM_PO__c = po.Id;
                    poPOSMLine.ASI_CTY_CN_Vendor_ReceiptOwner__c = quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_ReceiptOwner__c;
                    poPOSMLine.ASI_MFM_Contact_Person__c = quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_ContactName__c;
                    poPOSMLine.ASI_MFM_Detail_Address__c = quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Delivery_Address__c;
                    // poPOSMLine.ASI_MFM_City__c = quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Contact__r.MailingCity;
                    // poPOSMLine.ASI_MFM_Province__c = quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Contact__r.MailingState;
                    poPOSMLine.ASI_MFM_Phone_Number__c = quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Receipt_Phone__c;
                    poPOSMLine.ASI_MFM_Delivery_Address_Outlet__c = quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Outlet__c;
                    if(null != quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Warehouse__c)
                    {
                        poPOSMLine.ASI_MFM_Delivery_Address_Warehouse__c = quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Warehouse__c;
                    }
                    else
                    {
                        if(wareList != null && wareList.size() > 0) { 
                            poPOSMLine.ASI_MFM_Delivery_Address_Warehouse__c = wareList.get(0).Id;
                        }
                    }

                    poPOSMLine.ASI_CTY_CN_Vendor_Freight__c = quoteline.ASI_CTY_CN_Vendor_Freight__c;
                    poPOSMLine.ASI_MFM_Tax_Code__c = taxCodes.isEmpty() ? null : taxCodes[0].Id;
                    poPOSMLine.ASI_MFM_Supplier_Email__c = po.ASI_MFM_Supplier_Email__c;
                    poPOSMLine.ASI_MFM_Budget_Owner__c = po.ASI_MFM_Budget_Owner__c;

                    ASI_FOC_Warehouse__c wh = null;
                    if (warehouseMap.containsKey(quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Warehouse__c)) {
                        wh = warehouseMap.get(quoteline.ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Warehouse__c);
                    } else {
                        if(wareList != null && wareList.size() > 0) { 
                            wh = warehouseMap.get(wareList.get(0).Id);
                        }
                    }

                    if (wh != null) {
                        if (wh.ASI_FOC_City__c != null) {
                            poPOSMLine.ASI_MFM_City__c = wh.ASI_FOC_City__r.Name;
                        }
                        if (wh.ASI_FOC_City__r.ASI_CRM_CN_Province__c != null) {
                            poPOSMLine.ASI_MFM_Province__c = wh.ASI_FOC_City__r.ASI_CRM_CN_Province__r.Name;
                        }
                        poPOSMLine.ASI_MFM_SIR_Email_Address_1__c = wh.ASI_FOC_SIR_Email_Address_1__c;
                        poPOSMLine.ASI_MFM_SIR_Email_Address_2__c = wh.ASI_FOC_SIR_Email_Address_2__c;
                        poPOSMLine.ASI_MFM_SIR_Email_Address_3__c = wh.ASI_FOC_SIR_Email_Address_3__c;
                        poPOSMLine.ASI_MFM_SIR_Email_Address_4__c = wh.ASI_FOC_SIR_Email_Address_4__c;
                        poPOSMLine.ASI_MFM_SIR_Email_Address_5__c = wh.ASI_FOC_SIR_Email_Address_5__c;
                        poPOSMLine.ASI_MFM_SIR_Email_Address_6__c = wh.ASI_FOC_SIR_Email_Address_6__c;
                        poPOSMLine.ASI_MFM_SIR_Email_Address_7__c = wh.ASI_FOC_SIR_Email_Address_7__c;
                        poPOSMLine.ASI_MFM_SIR_Email_Address_8__c = wh.ASI_FOC_SIR_Email_Address_8__c;

                        poPOSMLine.ASI_MFM_Operation_Team_Email_1__c = wh.ASI_MFM_Operation_Team_Email_1__c;
                        poPOSMLine.ASI_MFM_Operation_Team_Email_2__c = wh.ASI_MFM_Operation_Team_Email_2__c;
                        poPOSMLine.ASI_MFM_Operation_Team_Email_3__c = wh.ASI_MFM_Operation_Team_Email_3__c;
                        poPOSMLine.ASI_MFM_Operation_Team_Email_4__c = wh.ASI_MFM_Operation_Team_Email_4__c;
                        poPOSMLine.ASI_MFM_Operation_Team_Email_5__c = wh.ASI_MFM_Operation_Team_Email_5__c;
                        poPOSMLine.ASI_MFM_Operation_Team_Email_6__c = wh.ASI_MFM_Operation_Team_Email_6__c;
                        poPOSMLine.ASI_MFM_Operation_Team_Email_7__c = wh.ASI_MFM_Operation_Team_Email_7__c;
                        poPOSMLine.ASI_MFM_Operation_Team_Email_8__c = wh.ASI_MFM_Operation_Team_Email_8__c;
                    }
                    
                    LPOSMLineList.add(poPOSMLine);
                }
            }
        }
        if (!LPOSMLineList.isEmpty()) {
            insert LPOSMLineList;
        }
        //update POList;
    }

    public static ASI_MFM_PO_Line_Item__c generatePOLineItem(ASI_MFM_PO__c po) {
        ASI_MFM_PO_Line_Item__c poLineItem = new ASI_MFM_PO_Line_Item__c();
        poLineItem.RecordTypeId = G_RTID_POLINE;           
        poLineItem.ASI_MFM_From_eMarket__c = true;
        poLineItem.ASI_MFM_Purchase_Request_Line__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__c;
        poLineItem.ASI_MFM_G_L_Date__c = Date.today();
        poLineItem.ASI_MFM_BU_Code__c = po.ASI_MFM_BU_Code__c;
        poLineItem.ASI_MFM_A_C_Code__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.ASI_CTY_CN_Vendor_AC_Code__c;
        poLineItem.ASI_MFM_PO__c = po.Id;
        poLineItem.ASI_MFM_Sub_brand_Code__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_SubBrand__c;
        poLineItem.ASI_MFM_SKU_Code__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_Alternative_SKU__c;
        poLineItem.ASI_MFM_List_Item_Description__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.Name;
        poLineItem.ASI_MFM_Quantity__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Quantity__c;
        poLineItem.ASI_MFM_Unit_Price__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Unit_Price__c;
        poLineItem.ASI_MFM_Item_Group_Code__c = po.ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_MFM_Item_Group_Code__c;
        poLineItem.ASI_MFM_Amount__c = poLineItem.ASI_MFM_Quantity__c * poLineItem.ASI_MFM_Unit_Price__c;
        return poLineItem;
    }
}