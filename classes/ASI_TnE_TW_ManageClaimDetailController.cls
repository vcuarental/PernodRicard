/*********************************************************************************
 * Name: ASI_TnE_TW_ManageClaimDetailController
 * Description: Controller class for Managing T&E Claims.
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/11/2015       Laputa                  Created
 * 18/07/2016       Laputa:Hugo Cheung      Update. Add a variable gnhType to wrapper to show the classification G&H Type
 * 25/07/2016       Laputa:Hugo Cheung      Update. Change ASI_TnE_Payment_Amount__c to ASI_TnE_TW_Payment_Amount__c  
 * 13/12/2018       SH                      Update. Add a A&P/A&D checking if T&E line related to plan 
*/
public class ASI_TnE_TW_ManageClaimDetailController{
    public Id claimsId {get;set;}
    public String headerRecType {get;set;}
    public String usrLocale {get;set;} 
    public String recTypeName {get;set;}
    public Boolean isFinanceView {get;set;}
    public Boolean isFinanceType {get;set;}
    public String currencyStr {get;set;}
    public String categoryType {get;set;}
    public Boolean isEmployeeView {get;set;}
    public Id claimDetailRecordType {get;set;}
    public Id employeeMappingRecordType {get;set;}
    public Boolean marketChargedEnabled {get;set;}
    public ASI_TnE_ClaimHeader__c claimHeader {get;set;}
    public List<ASI_TnE_ClaimDetail__c> claimDetailDelete {get;set;}
    public List<claimDetailWrapper> detailWrapper {get;set;}
    public Map<String, List<ASI_JP_TnE_Expense_Classification__c>> fClassification{get;set;}
    public Map<String, ASI_MFM_Exchange_Rate__c> exchangeRates {get;set;}
    public Map<String, List<ASI_MFM_Exchange_Rate__c>> exchangeRatesTW{get;set;}
    public User ownerUser {get;set;}
    public User payeeEmployeeUser {get;set;}
    public boolean isTaxApplicable {get;set;}
    public boolean isSaveError {get;set;}
    public String PARAM_CATEGORIES_IDS {get;set;}
    public String PARAM_CLASSIFICATIONS_IDS {get;set;} 
    public Id greetingId{get;set;}
    public Id greetingCatId{get;set;}
    
    public List<ASI_JP_TnE_Expense_Category__c> categories {get;set;}
    public List<ASI_JP_TnE_Expense_Classification__c> classifications {get;set;}

    public List<SelectOption> SubBrandSelectOptions {get;set;}

    public Map<ID, ASI_JP_TnE_Expense_Classification__c> allClassificationMap {get;set;}
    
    public ASI_TnE_TW_ManageClaimDetailController(ApexPages.StandardController con){
        this.allClassificationMap = new Map<ID, ASI_JP_TnE_Expense_Classification__c>();
        this.claimsId = ApexPages.currentPage().getParameters().get('id');
        usrLocale = UserInfo.getLocale();
        // retrieve T&E Claim
        claimHeader =  new ASI_TnE_ClaimHeader__c();
        claimHeader = retrieveClaimHeader();
        isSaveError = false;
        claimDetailDelete = new List<ASI_TnE_ClaimDetail__c>();
        String subBrandName = '';
        // recordTypes
        headerRecType = '';
        currencyStr = 'TWD';
        if(claimHeader.Recordtype.DeveloperName.contains('ASI_TnE_TW')){
            headerRecType = 'TW';
            recTypeName = 'T&E TW Claim Detail';
            claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_TW_Claim_Detail');
            currencyStr = 'TWD';
            categoryType = 'ASI_TnE_TW_Expense_Category';
            employeeMappingRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_Employee_Code_Mapping__cASI_TnE_TW_Employee_Code_Mapping');
            subBrandName = 'ASI_TW_CRM_Sub_brand';
        }
        
        if(claimHeader.ASI_TnE_Currency__c != null && claimHeader.ASI_TnE_Currency__c != '') {
            currencyStr = claimHeader.ASI_TnE_Currency__c;
        }

        // default picklist values
        category_classification();
        // used in javascript and jquery in the vf page for dependent picklist functionality
        filtered_Classification();
        
        isFinanceView = false;
        isFinanceType = false;
        if(claimHeader.Recordtype.DeveloperName.contains('ASI_TnE_TW_Claim_Header_Finance')){
            isFinanceView = retrieveFinanceState('ASI_TnE_TW_Finance_Users');
            isFinanceType = true;
        }
        
        if(claimHeader.ASI_TnE_Status__c == 'Submitted'){
            if(claimHeader.Recordtype.DeveloperName.contains('ASI_TnE_TW_Claim_Header')){
                isFinanceView = retrieveFinanceState('ASI_TnE_TW_Finance_Users');
            }
            isFinanceType = true;
        } 
        
        // exchange Rates
        exchange_Rates();
        
        // retrieve all related T&E Claims Detail
        detailWrapper = new List<claimDetailWrapper>();
        detailWrapper = retrieveClaimDetailsWrap();
        
        // check if Finance or Employee View
        isEmployeeView = false;
        if(isFinanceType && isFinanceView && claimHeader.ASI_TnE_Status__c != 'Draft'){
            isEmployeeView = true;
        }
        if(claimHeader.ASI_TnE_Status__c != 'Draft'){
            isEmployeeView = true;
        }
        
        marketChargedEnabled = marketChargedEditable();
        
        Id ownerID = claimHeader.ownerid;
        ownerUser = [SELECT ID, Name, ASI_TnE_Department_Code__c, ASI_TnE_Sub_Ledger__c FROM User WHERE ID  = : ownerID].get(0);

        payeeEmployeeUser = null;
        if(claimHeader.ASI_TnE_Payee_Employee__c != null ) {
            payeeEmployeeUser = [SELECT ID, Name, ASI_TnE_Department_Code__c, ASI_TnE_Sub_Ledger__c FROM User WHERE ID  = : claimHeader.ASI_TnE_Payee_Employee__c].get(0);
        }
        
        isTaxApplicable = true;

        setSubBrandSelectOptions(subBrandName);

        this.allClassificationMap = new Map<ID,ASI_JP_TnE_Expense_Classification__c>([SELECT ID, Name, ASI_TnE_Required_Fields__c, ASI_JP_TnE_Tax_Flag__c, ASI_TnE_Read_Only_Fields__c, 
                                    ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c, ASI_TnE_WHT_Rate__c, ASI_TnE_GnH_Type__c
                                    FROM ASI_JP_TnE_Expense_Classification__c 
                                    WHERE ASI_JP_TnE_Expense_Category__r.recordtype.developername = : this.categoryType]);
    }
    
    // retrieve T&E Claim Header
    private ASI_TnE_ClaimHeader__c retrieveClaimHeader(){
        ASI_TnE_ClaimHeader__c claim =  new ASI_TnE_ClaimHeader__c();
        Map<String, Schema.SObjectField> claimFieldMap = Schema.SObjectType.ASI_TnE_ClaimHeader__c.fields.getMap();
        String claimQuery = 'Select ';
            
        for(String fields  : claimFieldMap.keySet()){
            claimQuery += fields + ' ,';
        }
             
        claimQuery = claimQuery.subString(0,claimQuery.length()-1);
        claimQuery += ', Recordtype.Developername ' +
                        ' From ASI_TnE_ClaimHeader__c' +
                        ' Where  Id = ' + '\'' + claimsId + '\' ';
         
        List<ASI_TnE_ClaimHeader__c> claimList = (List<ASI_TnE_ClaimHeader__c>)Database.query(claimQuery); 
        if(claimList.size() > 0){
            claim = claimList.get(0);
        }
        return claim;
    }
    
    // retrieve T&E Claim Detail
    private List<claimDetailWrapper> retrieveClaimDetailsWrap(){
        List<claimDetailWrapper> claimDetailWrap = new List<claimDetailWrapper>();
        if(claimsId != null){
            Map<String, Schema.SObjectField> claimDetailFieldMap = Schema.SObjectType.ASI_TnE_ClaimDetail__c.fields.getMap();
            String claimDetailQuery = 'Select ASI_TnE_SubBrand__r.name, ';
            
            for(String fields  : claimDetailFieldMap.keySet()){
                claimDetailQuery += fields + ' ,';
            }

            claimDetailQuery = claimDetailQuery.subString(0,claimDetailQuery.length()-1);
            claimDetailQuery += ', ASI_TnE_Expense_Category__r.Name, ASI_TnE_Expense_Classification__r.Name, ASI_TnE_Expense_Classification__r.ASI_TnE_GnH_Type__c' + 
                                ' From ASI_TnE_ClaimDetail__c' +
                                ' Where ASI_TnE_ClaimHeader__c = ' + '\'' + claimsId + '\' ORDER BY ID ASC';

            List<ASI_TnE_ClaimDetail__c> claimDetailList = (List<ASI_TnE_ClaimDetail__c>)Database.query(claimDetailQuery);
            
            Integer rowIndex = 0;
            for(ASI_TnE_ClaimDetail__c cdL : claimDetailList){
                rowIndex++;
                claimDetailWrap.add(new claimDetailWrapper(rowIndex, headerRecType, cdL, cdL.ASI_TnE_Expense_Category__c, cdL.ASI_TnE_Expense_Classification__c, cdL.ASI_TnE_Expense_Classification__r.ASI_TnE_GnH_Type__c));
            }
        }
        return claimDetailWrap;
    }
    
    private Boolean retrieveFinanceState(String pGroupDevName){
        String userId = UserInfo.getUserId();
        Boolean financeView = false;
        List<Group> publicGroup = new List<Group>();
        publicGroup = [Select Id, DeveloperName From Group Where DeveloperName =: pGroupDevName];
        if(publicGroup.size() > 0){
            for(GroupMember grpM :[Select Id, UserOrGroupId From GroupMember Where GroupId =: publicGroup[0].Id]){
                if(grpM.UserOrGroupId == userId){
                    financeView = true;
                }
            }
        }
        return financeView;
    }
    
    private Boolean marketChargedEditable(){
        Set<Id> claimEmployee = new Set<Id>();
        Boolean marketCharged = false;
        for(ASI_TnE_Employee_Code_Mapping__c empMap :[Select Id, ASI_TnE_Employee_Name__c, RecordTypeId From ASI_TnE_Employee_Code_Mapping__c 
                                                        Where RecordTypeId =: employeeMappingRecordType]){
            claimEmployee.add(empMap.ASI_TnE_Employee_Name__c);
        }
        
        if(claimEmployee.size() > 0){
            if(claimEmployee.contains(claimHeader.OwnerId)){
                marketCharged = true;
            }
            if(claimHeader.ASI_TnE_Payee_Employee__c != null && claimEmployee.contains(claimHeader.ASI_TnE_Payee_Employee__c)){
                marketCharged = true;
            }
        }
        return marketCharged;
    }
    
    public void updateWrapperValues(){
        Map<Integer, String> categoryMap = new Map<Integer, String>();
        Map<Integer, String> classificationMap = new Map<Integer, String>();
        system.debug('***PARAM: ' + PARAM_CATEGORIES_IDS + '\n' + PARAM_CLASSIFICATIONS_IDS);
        categoryMap = map_Category_Classification(PARAM_CATEGORIES_IDS);
        classificationMap = map_Category_Classification(PARAM_CLASSIFICATIONS_IDS);
        
        for(claimDetailWrapper wrp: detailWrapper){
            if(categoryMap.get(wrp.rowIndex) != null && !categoryMap.get(wrp.rowIndex).contains('undefined') && !categoryMap.get(wrp.rowIndex).contains('null')){
                wrp.detailRecord.ASI_TnE_Expense_Category__c = categoryMap.get(wrp.rowIndex);
                wrp.expCategory = categoryMap.get(wrp.rowIndex);
            }
            if(classificationMap.get(wrp.rowIndex) != null && !classificationMap.get(wrp.rowIndex).contains('undefined') && !classificationMap.get(wrp.rowIndex).contains('null')){
                wrp.detailRecord.ASI_TnE_Expense_Classification__c = classificationMap.get(wrp.rowIndex);
                wrp.gnhType = allClassificationMap.containsKey(classificationMap.get(wrp.rowIndex)) ? allClassificationMap.get(classificationMap.get(wrp.rowIndex)).ASI_TnE_GnH_Type__c : '';
                wrp.expClassification = classificationMap.get(wrp.rowIndex);
            }
        }
    }
    
    // add new TnE Detail row
    public void addNewDetail(){
        updateWrapperValues();
        
        Id category = null;
        Id classification = null;
        if(categories.size() > 0){
            category = categories[0].Id;
        }
        if(classifications.size() > 0){
            classification = classifications[0].Id;
        }
        
        Decimal fxRate = 1;

        ASI_TnE_ClaimDetail__c newDetailRec = new ASI_TnE_ClaimDetail__c(
            ASI_TnE_Receipt_Date__c = Date.Today(),
            ASI_TnE_Currency__c = currencyStr,
            ASI_TnE_ClaimHeader__c = claimHeader.Id,
            RecordTypeId = claimDetailRecordType,
            ASI_TnE_Receipt_Amount__c = 0.00,
            ASI_TnE_With_Receipt__c = true,
            ASI_TnE_Expense_Category__c = category,
            ASI_TnE_Expense_Classification__c = classification,
            ASI_TnE_FX_Rate__c = fxRate
        );
        
        Integer rowIndex = detailWrapper.size() + 1;
        claimDetailWrapper wrapperLine = new claimDetailWrapper(rowIndex, headerRecType, newDetailRec, newDetailRec.ASI_TnE_Expense_Category__c, newDetailRec.ASI_TnE_Expense_Classification__c, '');
        wrapperLine.subBrandSelectOption = SubBrandSelectOptions;
        detailWrapper.add(wrapperLine);
    }

    // save claim Detail
    public Pagereference saveClaimDetails(){
        Pagereference ref;
        Map<Integer, String> categoryMap = new Map<Integer, String>();
        Map<Integer, String> classificationMap = new Map<Integer, String>();
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);

        categoryMap = map_Category_Classification(PARAM_CATEGORIES_IDS);
        classificationMap = map_Category_Classification(PARAM_CLASSIFICATIONS_IDS);
        System.debug('============ categoryMap' + categoryMap);
        System.debug('============ categoryMap' + classificationMap);
        
        try{
            List<ASI_TnE_ClaimDetail__c> claimDetailUpsert = new List<ASI_TnE_ClaimDetail__c>();
            List<ASI_TnE_Tax_Date_Mapping__c> taxMap = ASI_TnE_Tax_Date_Mapping__c.getAll().values();
            Map<String, ASI_TnE_Employee_Code_Mapping__c> empCodeMap = new Map<String, ASI_TnE_Employee_Code_Mapping__c>();
            for(ASI_TnE_Employee_Code_Mapping__c empMap :[Select Id, ASI_TnE_Employee_Name__c, RecordTypeId, ASI_TnE_Department_Code__c, ASI_TnE_Employee_Code__c, ASI_TnE_Market__c
                                                            From ASI_TnE_Employee_Code_Mapping__c 
                                                            Where RecordTypeId =: employeeMappingRecordType]){
                if(empMap.ASI_TnE_Employee_Name__c != null && empMap.ASI_TnE_Market__c != ''){
                    empCodeMap.put(empMap.ASI_TnE_Employee_Name__c + empMap.ASI_TnE_Market__c, empMap);
                }
            }
            
            Decimal rptNumber = 1;
            isSaveError = false;
            
            Decimal totalPaymentAmount = 0;
            Decimal totalAmountApproved = claimHeader.ASI_TnE_Total_Amount_Approved__c != null ? claimHeader.ASI_TnE_Total_Amount_Approved__c : 0;
            
            Map<ID, Account> accountMap = new Map<ID, Account>();
            //Map<ID, ASI_MFM_A_C_Code__c> acCodeMap = new Map<ID, ASI_MFM_A_C_Code__c>();
            Map<String, String> acCodeMap = new Map<String, String>();
            
            if(headerRecType == 'TW') {
                Set<ID> accChargeToIds = new Set<ID>();
                Set<ID> acCodes = new Set<ID>();
                for(claimDetailWrapper wrp: detailWrapper){
                    if(wrp.detailRecord.ASI_TnE_Charge_To_Acc__c != null) {
                        accChargeToIds.add(wrp.detailRecord.ASI_TnE_Charge_To_Acc__c);
                    }
                    /*if(wrp.detailRecord.ASI_TnE_A_C_Code__c != null) {
                        acCodes.add(wrp.detailRecord.ASI_TnE_A_C_Code__c);
                    }*/
                }

                if(accChargeToIds.size() > 0) {
                    accountMap = new Map<ID, Account>([SELECT ID, Name, ASI_MFM_Customer_Supplier_Number__c FROM Account WHERE ID IN : accChargeToIds]);
                }

                //if(acCodes.size() > 0) {
                    //acCodeMap = new Map<ID, ASI_MFM_A_C_Code__c>([SELECT ID, Name, ASI_MFM_A_C_Code__c FROM ASI_MFM_A_C_Code__c WHERE ID IN : acCodes]);
                //}
                for(ASI_MFM_A_C_Code__c ac: [Select ASI_MFM_A_C_Code__c,ASI_MFM_A_and_P_Tree__c from asi_mfm_a_c_code__c where recordtype.name ='TW A/C Code']){
                    acCodeMap.put(ac.ASI_MFM_A_C_Code__c, ac.ASI_MFM_A_And_P_Tree__c);
                }
            }
            Integer rowNum = 1;
            for(claimDetailWrapper wrp: detailWrapper){
                totalPaymentAmount += (wrp.detailRecord.ASI_TnE_Receipt_Amount__c != null ? wrp.detailRecord.ASI_TnE_Receipt_Amount__c : 0) * (wrp.detailRecord.ASI_TnE_FX_Rate__c != null ? wrp.detailRecord.ASI_TnE_FX_Rate__c : 0);
                
                //Override TW sub-ledger logic depending on  A/C code OR Expense Classification Account Code
                boolean overrideLedger = false;
                if(headerRecType == 'TW') {
                    /*
                    if(wrp.detailRecord.ASI_TnE_A_C_Code__c != null) {
                        if(acCodeMap.get(wrp.detailRecord.ASI_TnE_A_C_Code__c).ASI_MFM_A_C_Code__c == '1270.060000') {
                            overrideLedger = true;
                        }
                    }
                    */
                    // [SH] 2018-12-13 *** Need to choose Expense Classification with A&C/A&D Code if plan related
                    if(wrp.detailRecord.ASI_TnE_Expense_Classification__c != null) {
                       if(allClassificationMap.get(wrp.detailRecord.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c == '1270.060000' ) {
                            overrideLedger = true;
                        }
                        if(wrp.detailRecord.ASI_TnE_CAP_Plan__c != null){
                            if(acCodeMap.get(allClassificationMap.get(wrp.detailRecord.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c)!=null){
                                if(!acCodeMap.get(allClassificationMap.get(wrp.detailRecord.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c).contains('A&P') &&
                                   !acCodeMap.get(allClassificationMap.get(wrp.detailRecord.ASI_TnE_Expense_Classification__c).ASI_JP_TnE_Account_Mapping__r.ASI_TnE_Account_Number__c).contains('A&D')){
                                       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,'Row ' + rowNum + ': [' + allClassificationMap.get(wrp.detailRecord.ASI_TnE_Expense_Classification__c).name + '] : You must select the expense classification with A&P/A&D A/C Code'));                                       
                                       isSaveError = true;
                                       //return null;
                                   }
                            }else{
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,'Row ' + rowNum + ': [' + allClassificationMap.get(wrp.detailRecord.ASI_TnE_Expense_Classification__c).name + '] : You must select the expense classification with A&P/A&D A/C Code'));                                       
                                isSaveError = true;
                                //return null;
                            }
                        }
                    }
                    // END - [SH]
                    
                }

                wrp.detailRecord.ASI_TnE_SG_Sub_Ledger__c = ownerUser.ASI_TnE_Sub_Ledger__c;
                
                system.debug('wrp.detailRecord.ASI_TnE_SubBrand__c'+wrp.detailRecord.ASI_TnE_SubBrand__c);
                system.debug('wrp.targetSubBrandSelected'+wrp.targetSubBrandSelected);

                wrp.detailRecord.ASI_TnE_SubBrand__c = wrp.targetSubBrandSelected;

                ID userIDMarketCharge = ownerUser.id;

                if(claimHeader.ASI_TnE_Payee_Employee__c != null){
                    if(empCodeMap.get(claimHeader.ASI_TnE_Payee_Employee__c + wrp.detailRecord.ASI_TnE_Market_Charged_To__c) != null){
                        wrp.detailRecord.ASI_TnE_SG_Sub_Ledger__c = empCodeMap.get(claimHeader.ASI_TnE_Payee_Employee__c + wrp.detailRecord.ASI_TnE_Market_Charged_To__c).ASI_TnE_Employee_Code__c;
                        userIDMarketCharge = claimHeader.ASI_TnE_Payee_Employee__c;
                    } else if(payeeEmployeeUser != null) {
                        wrp.detailRecord.ASI_TnE_SG_Sub_Ledger__c = payeeEmployeeUser.ASI_TnE_Sub_Ledger__c;
                    }
                }

                if(wrp.detailRecord.ASI_TnE_Market_Charged_To__c != '' && wrp.detailRecord.ASI_TnE_Market_Charged_To__c != null){
                    if(empCodeMap.get(userIDMarketCharge + wrp.detailRecord.ASI_TnE_Market_Charged_To__c) != null){
                        wrp.detailRecord.ASI_TnE_SG_Sub_Ledger__c = empCodeMap.get(userIDMarketCharge + wrp.detailRecord.ASI_TnE_Market_Charged_To__c).ASI_TnE_Employee_Code__c;
                    }
                
                }
                
                if(categoryMap.get(wrp.rowIndex) != null && !categoryMap.get(wrp.rowIndex).contains('undefined') && !categoryMap.get(wrp.rowIndex).contains('null')){
                    wrp.detailRecord.ASI_TnE_Expense_Category__c = categoryMap.get(wrp.rowIndex);
                    wrp.expCategory = categoryMap.get(wrp.rowIndex);
                }
                if(classificationMap.get(wrp.rowIndex) != null && !classificationMap.get(wrp.rowIndex).contains('undefined') && !classificationMap.get(wrp.rowIndex).contains('null')){
                    wrp.detailRecord.ASI_TnE_Expense_Classification__c = classificationMap.get(wrp.rowIndex);
                    wrp.gnhType = allClassificationMap.containsKey(classificationMap.get(wrp.rowIndex)) ? allClassificationMap.get(classificationMap.get(wrp.rowIndex)).ASI_TnE_GnH_Type__c : '';
                    wrp.expClassification = classificationMap.get(wrp.rowIndex);
                }
                
                if(!(claimHeader.ASI_TnE_Type__c == 'Corp Card' && wrp.isClone) && headerRecType == 'TW') {
                    wrp.detailRecord.ASI_TnE_Receipt_Number__c = rptNumber;  
                }
                
                if(headerRecType == 'TW' && !overrideLedger) {
                    if(wrp.detailRecord.ASI_TnE_Charge_To_Acc__c != null) {
                        //wrp.detailRecord.ASI_TnE_SG_Sub_Ledger__c = accountMap.get(wrp.detailRecord.ASI_TnE_Charge_To_Acc__c).ASI_MFM_Customer_Supplier_Number__c; //20170202, Elufa
                        wrp.detailRecord.ASI_TnE_SG_Sub_Ledger__c = accountMap.get(wrp.detailRecord.ASI_TnE_Charge_To_Acc__c).Name; //20170202, Elufa
                    }
                }
                for(ASI_TnE_Tax_Date_Mapping__c tax:taxMap){
                    if(wrp.detailRecord.ASI_TnE_Tax_Inclusive__c && tax.ASI_TnE_Record_Type__c == Global_RecordTypeCache.getRt(wrp.detailRecord.recordTypeid).developerName &&
                            tax.ASI_TnE_Start_Date__c <= wrp.detailRecord.ASI_TnE_Receipt_Date__c &&
                            tax.ASI_TnE_End_Date__c >= wrp.detailRecord.ASI_TnE_Receipt_Date__c){
                        wrp.detailRecord.ASI_TnE_Tax_Rate__c = tax.ASI_TnE_Tax_Rate__c;        
                    }
                }
                Decimal taxRate = wrp.detailRecord.ASI_TnE_Tax_Rate__c != null ? wrp.detailRecord.ASI_TnE_Tax_Rate__c : 0;
                taxRate = taxRate/100;
                Decimal paymentAmount = (wrp.detailRecord.ASI_TnE_Receipt_Amount__c != null ? wrp.detailRecord.ASI_TnE_Receipt_Amount__c : 0) * (wrp.detailRecord.ASI_TnE_FX_Rate__c != null ? wrp.detailRecord.ASI_TnE_FX_Rate__c : 0);

                if(wrp.detailRecord.ASI_TnE_Tax_Inclusive__c && !(isFinanceType == true && isFinanceView == true)) {
                    wrp.detailRecord.ASI_TnE_Taxable_Amount__c = (paymentAmount / (1 + taxRate)).setScale(0, RoundingMode.HALF_UP);
                    wrp.detailRecord.ASI_TnE_Tax_Amount__c = (paymentAmount - ((paymentAmount/(1+(taxRate))).setScale(0, RoundingMode.HALF_UP))).setScale(0, RoundingMode.HALF_UP);
                }else if(!wrp.detailRecord.ASI_TnE_Tax_Inclusive__c){
                    wrp.detailRecord.ASI_TnE_Taxable_Amount__c  = paymentAmount;
                    wrp.detailRecord.ASI_TnE_Tax_Amount__c = 0;
                }
                
                if(wrp.detailRecord.ASI_TnE_Currency__c == 'TWD') {
                    wrp.detailRecord.ASI_TnE_TW_Payment_Amount__c = paymentAmount.setScale(0);
                } else {
                    wrp.detailRecord.ASI_TnE_TW_Payment_Amount__c = paymentAmount.setScale(2);
                }

                if(wrp.detailRecord.ASI_TnE_Expense_Category__c != greetingCatId && wrp.detailRecord.ASI_TnE_Expense_Classification__c == greetingId){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,'Row ' + rowNum + ': You must select the expense classification after selecting the expense category!'));
                    isSaveError = true;
                    //return null;
                }
                claimDetailUpsert.add(wrp.detailRecord);
                rptNumber++;
                rowNum++;
            }
            
            //Custom validation for corp card
            if(claimHeader.ASI_TnE_Type__c == 'Corp Card') {
                if(totalPaymentAmount != totalAmountApproved) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,'Total Payment Amount must be equal to the Total Amount Approved for Corp Card'));
                    isSaveError = true;
                    //return null;
                }
            }
            
            if(isSaveError==true)
                return null;
            
            // delete records removed from the table
            system.debug('***claimDetailDelete: ' + claimDetailDelete);
            if(claimDetailDelete.size() > 0){
                delete claimDetailDelete;
                claimDetailDelete.clear();
            }
            
            // save or update claim details 
            system.debug('***claimDetailUpsert: ' + claimDetailUpsert);
            if(claimDetailUpsert.size() > 0){
                List<ASI_TnE_ClaimDetail__c> claimDetailInsert = new List<ASI_TnE_ClaimDetail__c>();
                List<ASI_TnE_ClaimDetail__c> claimDetailUpdate = new List<ASI_TnE_ClaimDetail__c>();

                for(ASI_TnE_ClaimDetail__c claimDetail : claimDetailUpsert) {
                    if(String.isNotBlank(claimDetail.Id)) {
                        claimDetailUpdate.add(claimDetail);
                    } else {
                        claimDetailInsert.add(claimDetail);
                    }
                }
				     
                if(claimDetailUpdate.size() > 0 ) {
                    update claimDetailUpdate;
                }
                
                if(claimDetailInsert.size() > 0) {
                    insert claimDetailInsert;
                }

            }
            claimDetailDelete = new List<ASI_TnE_ClaimDetail__c>();
        }catch(DmlException e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,e.getDMLMessage(0)));
            isSaveError = true;
            return null;
        }
        
        if(isQuickSave) {
            return null;
        } else {
            return redirectClaimHeaderPage();
        }
        
    }
    
    public pageReference redirectClaimHeaderPage(){
        Pagereference ref;
        if(isSaveError) {
            return null;
        }
        ref = new PageReference('/' + claimHeader.Id);
        ref.setRedirect(true);

        return ref;
    }
    
    // cancel and return to the header standard page
    public PageReference cancel(){
        Pagereference ref;
        ref = new PageReference('/'+claimHeader.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    // clone claim Detail
    public void cloneClaimDetail(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_claimDetail = params.get('PARAM_CLONE_CLAIM_DETAIL_ID');
        
        Map<Integer, String> categoryMap = new Map<Integer, String>();
        Map<Integer, String> classificationMap = new Map<Integer, String>();
        system.debug('***PARAM: ' + PARAM_CATEGORIES_IDS + '\n' + PARAM_CLASSIFICATIONS_IDS);
        categoryMap = map_Category_Classification(PARAM_CATEGORIES_IDS);
        classificationMap = map_Category_Classification(PARAM_CLASSIFICATIONS_IDS);
        
        for(claimDetailWrapper wrp: detailWrapper){
            if(categoryMap.get(wrp.rowIndex) != null && !categoryMap.get(wrp.rowIndex).contains('undefined') && !categoryMap.get(wrp.rowIndex).contains('null')){
                wrp.detailRecord.ASI_TnE_Expense_Category__c = categoryMap.get(wrp.rowIndex);
                wrp.expCategory = categoryMap.get(wrp.rowIndex);
            }
            if(classificationMap.get(wrp.rowIndex) != null && !classificationMap.get(wrp.rowIndex).contains('undefined') && !classificationMap.get(wrp.rowIndex).contains('null')){
                wrp.detailRecord.ASI_TnE_Expense_Classification__c = classificationMap.get(wrp.rowIndex);
                wrp.expClassification = classificationMap.get(wrp.rowIndex);
            }
        }
        
        ASI_TnE_ClaimDetail__c claimDetailTemp = new ASI_TnE_ClaimDetail__c();
        ASI_TnE_ClaimDetail__c claimDetailClone = new ASI_TnE_ClaimDetail__c();
        String tempGnHType = '';
        
        for(claimDetailWrapper wrp: detailWrapper){
            if(wrp.rowIndex == Integer.valueOf(param_claimDetail)){
                claimDetailTemp = wrp.detailRecord;
                tempGnHType = wrp.gnhType;
            }
        }
        claimDetailClone = claimDetailTemp.clone(false, true, false, false);
        
        Integer rowIndex = detailWrapper.size() + 1;
        claimDetailWrapper wrapperLine = new claimDetailWrapper(rowIndex, headerRecType, claimDetailClone, claimDetailClone.ASI_TnE_Expense_Category__c, claimDetailClone.ASI_TnE_Expense_Classification__c, tempGnHType);
        wrapperLine.subBrandSelectOption = SubBrandSelectOptions;
        wrapperLine.isClone = true;
        detailWrapper.add(wrapperLine);
    }
    
    // remove record in the table
    public void removeClaimDetail(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_claimDetail = params.get('PARAM_DELETE_CLAIM_DETAIL_ID');
        
        Map<Integer, String> categoryMap = new Map<Integer, String>();
        Map<Integer, String> classificationMap = new Map<Integer, String>();
        system.debug('***PARAM: ' + PARAM_CATEGORIES_IDS + '\n' + PARAM_CLASSIFICATIONS_IDS);
        categoryMap = map_Category_Classification(PARAM_CATEGORIES_IDS);
        classificationMap = map_Category_Classification(PARAM_CLASSIFICATIONS_IDS);

        for(claimDetailWrapper wrp: detailWrapper){
            if(categoryMap.get(wrp.rowIndex) != null && !categoryMap.get(wrp.rowIndex).contains('undefined') && !categoryMap.get(wrp.rowIndex).contains('null')){
                wrp.detailRecord.ASI_TnE_Expense_Category__c = categoryMap.get(wrp.rowIndex);
                wrp.expCategory = categoryMap.get(wrp.rowIndex);
            }
            if(classificationMap.get(wrp.rowIndex) != null && !classificationMap.get(wrp.rowIndex).contains('undefined') && !classificationMap.get(wrp.rowIndex).contains('null')){
                wrp.detailRecord.ASI_TnE_Expense_Classification__c = classificationMap.get(wrp.rowIndex);
                wrp.gnhType = allClassificationMap.containsKey(classificationMap.get(wrp.rowIndex)) ? allClassificationMap.get(classificationMap.get(wrp.rowIndex)).ASI_TnE_GnH_Type__c : '';
                wrp.expClassification = classificationMap.get(wrp.rowIndex);
            }
        }

        for(Integer i=0; i < detailWrapper.size(); i++){
            if(detailWrapper[i].rowIndex == Integer.valueOf(param_claimDetail)){
                if(detailWrapper[i].detailRecord.Id != null){
                    claimDetailDelete.add(detailWrapper[i].detailRecord);
                }
                detailWrapper.remove(i);
            }
        }
        
        Integer rowIndex = 0;
        for(claimDetailWrapper wrp: detailWrapper){
            rowIndex++;
            wrp.rowIndex = rowIndex;
        }
    }
    
    public void assignClassification() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        Integer rowID = Integer.valueOf(params.get('ROWID'));
        String categoryID = params.get('CATEGORY');
        String classificationID = params.get('CLASSIFICATION');
        system.debug('categoryid: ' + categoryID + ' classificationid: ' + classificationID);
        Map<Integer, String> categoryMap = new Map<Integer, String>();
        Map<Integer, String> classificationMap = new Map<Integer, String>();
        system.debug('***PARAM: ' + PARAM_CATEGORIES_IDS + '\n' + PARAM_CLASSIFICATIONS_IDS);
        categoryMap = map_Category_Classification(PARAM_CATEGORIES_IDS);
        classificationMap = map_Category_Classification(PARAM_CLASSIFICATIONS_IDS);

        for(claimDetailWrapper wrp: detailWrapper){
            if(categoryMap.get(wrp.rowIndex) != null && !categoryMap.get(wrp.rowIndex).contains('undefined') && !categoryMap.get(wrp.rowIndex).contains('null')){
                wrp.detailRecord.ASI_TnE_Expense_Category__c = categoryMap.get(wrp.rowIndex);
                wrp.expCategory = categoryMap.get(wrp.rowIndex);
            }
            if(classificationMap.get(wrp.rowIndex) != null && !classificationMap.get(wrp.rowIndex).contains('undefined') && !classificationMap.get(wrp.rowIndex).contains('null')){
                wrp.detailRecord.ASI_TnE_Expense_Classification__c = classificationMap.get(wrp.rowIndex);
                wrp.gnhType = allClassificationMap.containsKey(classificationMap.get(wrp.rowIndex)) ? allClassificationMap.get(classificationMap.get(wrp.rowIndex)).ASI_TnE_GnH_Type__c : '';
                wrp.expClassification = classificationMap.get(wrp.rowIndex);
            }
        }

        for(Integer i=0; i < detailWrapper.size(); i++){
            if(detailWrapper[i].rowIndex == rowID){
                detailWrapper[i].detailRecord.ASI_TnE_Expense_Category__c = (ID)categoryID;
                detailWrapper[i].detailRecord.ASI_TnE_Expense_Classification__c = (ID)classificationID;
                ASI_JP_TnE_Expense_Classification__c thisClassification = allClassificationMap.get((ID)classificationID);
                if(thisClassification != null) {
                    detailWrapper[i].detailRecord.ASI_TnE_Tax_Inclusive__c = thisClassification.ASI_JP_TnE_Tax_Flag__c;
                    if(thisClassification.ASI_TnE_Read_Only_Fields__c != null) {
                        if(thisClassification.ASI_TnE_Read_Only_Fields__c.contains('ASI_TnE_Tax_Inclusive')) {
                            detailWrapper[i].detailRecord.ASI_TnE_Tax_Amount__c = 0;
                        }
                    }
                }
                break;
            }
        }
    }

    //update wrapper values for Categories and Classifications
    private Map<Integer, String> map_Category_Classification(String param){
        Map<Integer, String> tempMap = new Map<Integer, String>();
        if(param != null && param != ''){
            List<String> listStr = param.split('_');
            
            for(String lst :listStr){
                List<String> str = lst.split('-');
                tempMap.put(Integer.valueOf(str[0]), str[1]);
            }
        }
        return tempMap;
    }
    
    // fetch all Expense Classifications for each Expense Category
    public void filtered_Classification(){
        fClassification = new Map<String, List<ASI_JP_TnE_Expense_Classification__c>>();
        List<ASI_JP_TnE_Expense_Classification__c> clsfList = [Select Id, Name, ASI_JP_TnE_Expense_Category__c, ASI_JP_TnE_Expense_Category__r.Name, ASI_TnE_Read_Only_Fields__c, ASI_TnE_WHT_Rate__c, ASI_JP_TnE_Tax_Flag__c 
                                                    From ASI_JP_TnE_Expense_Classification__c
                                                    Order By ASI_JP_TnE_Expense_Category__r.Name, Name ASC];
        ASI_JP_TnE_Expense_Classification__c greetingCls = new ASI_JP_TnE_Expense_Classification__c();
        for(ASI_JP_TnE_Expense_Classification__c clsf :clsfList){
            if(clsf.ASI_JP_TnE_Expense_Category__r.Name == '--Please Select--'){
                greetingCls = clsf;
                greetingCatId = clsf.ASI_JP_TnE_Expense_Category__c;
                greetingId = clsf.Id;
            }
        }
        for(ASI_JP_TnE_Expense_Classification__c clsf :clsfList){
            if(clsf.Name != '--Please Select--'){
                if(!fClassification.keySet().contains(clsf.ASI_JP_TnE_Expense_Category__c)){
                    List<ASI_JP_TnE_Expense_Classification__c> clsfTemp = new List<ASI_JP_TnE_Expense_Classification__c>();
                    clsfTemp.add(greetingCls);
                    clsfTemp.add(clsf);
                    fClassification.put(clsf.ASI_JP_TnE_Expense_Category__c, clsfTemp);
                }else{
                    fClassification.get(clsf.ASI_JP_TnE_Expense_Category__c).add(clsf);
                }
            }
        }
    }
    
    // populate default value of select lists
    public void category_classification(){
        categories = new List<ASI_JP_TnE_Expense_Category__c>();
        classifications = new List<ASI_JP_TnE_Expense_Classification__c>();

        for(ASI_JP_TnE_Expense_Category__c cat :[Select Id, Name, RecordType.DeveloperName
                                                    From ASI_JP_TnE_Expense_Category__c
                                                    Where RecordType.DeveloperName =: categoryType
                                                    Order By ASI_JP_TnE_Expense_Category_Order__c ASC]){
            if(cat.Name != null && cat.Name != ''){
                categories.add(cat);
            }
        }
        
        if(categories.size() > 0){
            for(ASI_JP_TnE_Expense_Classification__c clsf :[Select Id, Name, ASI_JP_TnE_Expense_Category__c, ASI_TnE_WHT_Rate__c  
                                                        From ASI_JP_TnE_Expense_Classification__c 
                                                        Where ASI_JP_TnE_Expense_Category__c =: categories[0].Id
                                                        Order By Name ASC]){
                if(clsf.Name != null && clsf.Name != ''){
                    classifications.add(clsf);
                }
            }
        }
    }
    
    public void exchange_Rates(){
        exchangeRates = new Map<String, ASI_MFM_Exchange_Rate__c>();
        exchangeRatesTW = new Map<String, List<ASI_MFM_Exchange_Rate__c>>();
        date d = date.newInstance(system.today().year(), system.today().month(), 1).addMonths(-3);

        for(ASI_MFM_Exchange_Rate__c exR :[Select Id, ASI_MFM_Country__c, ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c 
                                            From ASI_MFM_Exchange_Rate__c Where ASI_MFM_Country__c =: headerRecType AND ASI_MFM_Base_Currency__c =: currencyStr Order By ASI_MFM_Effective_Date__c DESC]){
            if(!exchangeRates.keySet().contains(exR.ASI_MFM_Counter_Currency__c)){
                exchangeRates.put(exR.ASI_MFM_Counter_Currency__c, exR);
            }else{
                if(exR.ASI_MFM_Effective_Date__c > exchangeRates.get(exR.ASI_MFM_Counter_Currency__c).ASI_MFM_Effective_Date__c){
                    exchangeRates.put(exR.ASI_MFM_Counter_Currency__c, exR);
                }
            }
            if(headerRecType == 'TW' && exR.ASI_MFM_Effective_Date__c > d){
                if(exchangeRatesTW.get(exR.ASI_MFM_Counter_Currency__c) == null){
                    List<ASI_MFM_Exchange_Rate__c> tempRateList = new List<ASI_MFM_Exchange_Rate__c>();
                    tempRateList.add(exR);
                    exchangeRatesTW.put(exR.ASI_MFM_Counter_Currency__c, tempRateList);
                }else{
                    exchangeRatesTW.get(exR.ASI_MFM_Counter_Currency__c).add(exR);
                }
            }
        }
    }
    
    /*********************************
        T&E Claim Detail Wrapper
    *********************************/
    public class claimDetailWrapper{
        public Integer rowIndex {get;set;}
        public String countryCode {get;set;}
        public ASI_TnE_ClaimDetail__c detailRecord {get;set;}
        public String expCategory {get;set;}
        public String expClassification {get;set;}
        public String gnhType {get; set;}
        public boolean isClone {get;set;}

        public List<SelectOption> subBrandSelectOption {get;set;}
        public String targetSubBrandSelected {get;set;}
        
        public claimDetailWrapper(Integer rowIndex, String countryCode, ASI_TnE_ClaimDetail__c detailRecord, String expCategory, String expClassification, String gnhType){
            this.rowIndex = rowIndex;
            this.countryCode = countryCode;
            this.detailRecord = detailRecord;
            this.expCategory = expCategory;
            this.expClassification = expClassification;
            this.gnhType = gnhType;
            this.targetSubBrandSelected = (String)detailRecord.ASI_TnE_SubBrand__c;
            this.isClone = false;
        }
    } 

    public void setSubBrandSelectOptions(String subBrandName) 
    {

        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('',''));

        String query = 'SELECT Id, Name FROM ASI_MFM_Sub_Brand__c WHERE recordtype.developername = \''+subBrandName+'\' ';
            
        query += ' ORDER BY name ';
            
        List<ASI_MFM_Sub_Brand__c> subBrandQuery = (List<ASI_MFM_Sub_Brand__c>)Database.query(query); 
        
        for(ASI_MFM_Sub_Brand__c sb : subBrandQuery){
            result.add(new SelectOption(sb.id, sb.name));
        }
        SubBrandSelectOptions = result;

        setClaimDetailWrapper_SubBrand();
    }

    public void setClaimDetailWrapper_SubBrand() {
        for(claimDetailWrapper claimDetail : detailWrapper) {
            claimDetail.subBrandSelectOption = SubBrandSelectOptions;
        }
    }
    
    @RemoteAction
    public static String[] findSObjects(string obj, string qry, string rec) {
        system.debug('Entered the function!');
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';

        List<ASI_CRM_AccountsAdditionalField__c> lstOutlets = new List<ASI_CRM_AccountsAdditionalField__c>();
        map<string, id> map_recordtype =ASI_MFM_Function.getRecordTypeId('ASI_CRM_AccountsAdditionalField__c');


        try {
        lstOutlets =[SELECT Name,RecordTypeid FROM ASI_CRM_AccountsAdditionalField__c 
        WHERE RecordTypeid=:map_recordtype.get('ASI_CRM_TW_Outlet') 
        AND Name like :key
        ORDER BY NAME];

            for(ASI_CRM_AccountsAdditionalField__c sb : lstOutlets){
           results.add(sb.Name);  }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
   }
}