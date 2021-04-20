/*********************************************************************************
 * Name: ASI_MFM_CAP_TH_MgAll_PaymentController
 * Description: Controller class for Manage All page for Payment
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/04/2016       Laputa:Hugo             Created
 *              
*/
public class ASI_MFM_CAP_TH_MgAll_PaymentController {
    
    public final static String TH_AC_CODE_DEFAULT_NUMBER = '2281';

    public static String PAYMENT_LINE_TABLE_PREFIX {get{ return 'PaymentLineItemTable_';}}
    public static String PAYMENT_LINE_ITEM_NEWRECORD_PREFIX {get{ return 'zzzzzzPaymentNEWZ';}}
    
    public Integer PAYMENT_LINE_ITEM_NEWRECORD_COUNTER {get;set;}
    public ID headerID {get;set;}
    public ASI_MFM_Payment__c header {get;set;}
    public Map<String, paymentLineWrapper> allPaymentLineMap {get;set;}{allPaymentLineMap = new Map<String, paymentLineWrapper>();}
    
    public boolean isReadOnlyView {get;set;}
    public boolean isFinanceOnlyView {get;set;}
    
    public List<ASI_MFM_Payment_Line_Item__c> paymentLinesToDelete {get;set;}
    
    public List<SelectOption> acSelectionList {get;set;}{acSelectionList = new List<SelectOption>();}
    
    public boolean isAllNull {get;set;}
    public boolean isPaymentAmountNull {get;set;}
    public boolean isQtyxVapAmountNotPayment {get;set;}
    public boolean isWarnisAllNull {get;set;}
    public boolean isWarnisPaymentAmountNull {get;set;}
    public boolean isWarnisQtyxVapAmountNotPayment {get;set;}

    private ASI_MFM_A_C_Code__c defaultACCode;
    
    public ASI_MFM_CAP_TH_MgAll_PaymentController(ApexPages.StandardController stdCon) {
        
        this.isAllNull = false;
        this.isPaymentAmountNull = false;
        this.isQtyxVapAmountNotPayment = false;
        this.isWarnisAllNull = false;
        this.isWarnisPaymentAmountNull = false;
        this.isWarnisQtyxVapAmountNotPayment = false;
        
        this.headerId = ApexPages.currentPage().getParameters().get('id');
        header = [SELECT Id, 
                         Name, 
                         ASI_MFM_Status__c, 
                         ASI_MFM_Supplier_Name__c, 
                         ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c,
                         ASI_MFM_Currency__c,
                         ASI_MFM_Payment_Type__c,
                         ASI_MFM_Exchange_Rate__c,
                         ASI_MFM_Invoice_Number__c,
                         ASI_MFM_Payment_Amount__c,
                         ASI_MFM_Invoice_Date__c
                     FROM ASI_MFM_Payment__c
                        WHERE Id = :headerId 
                           LIMIT 1];
        
        paymentLinesToDelete = new List<ASI_MFM_Payment_Line_Item__c>();
        
        //Retrieve all existing Payment Lines
        List<ASI_MFM_Payment_Line_Item__c> paymentLineList = (List<ASI_MFM_Payment_Line_Item__c>)queryAll(header.id, ' ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ', 'ASI_MFM_Payment_Line_Item__c', 'ASI_MFM_Payment__c', '');
        
        List<ASI_MFM_A_C_Code__c> acList = [SELECT ID, Name FROM ASI_MFM_A_C_Code__c WHERE recordtype.developername = 'ASI_MFM_CAP_TH_A_C_Code'];
        
        for(ASI_MFM_A_C_Code__c ac : acList) {
            if(ac.Name.startsWith(TH_AC_CODE_DEFAULT_NUMBER)) {

                 acSelectionList.add(new SelectOption(ac.Id, ac.Name));

                 if(ac.Name.startsWith(TH_AC_CODE_DEFAULT_NUMBER + '.' + header.ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c)) {
                    defaultACCode = ac;
                 }

            }
        }

        for(ASI_MFM_Payment_Line_Item__c paymentLine : paymentLineList) {
            paymentLine.ASI_MFM_A_C_Code__c = defaultACCode.Id;

            paymentLineWrapper paymentLineItemWrap = new paymentLineWrapper(paymentLine, acSelectionList);
            
            allPaymentLineMap.put((String)paymentLine.id, paymentLineItemWrap);
        }

        if(header.ASI_MFM_Status__c != 'Draft') {
            this.isReadOnlyView = true; 
        } else {
           this.isReadOnlyView = false; 
        }

        boolean isFinanceGroup = retrieveFinanceState('ASI_MFM_CAP_TH_Finance');
        this.isFinanceOnlyView = isFinanceGroup && isReadOnlyView;
        
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

    private List<sObject> queryAll(ID filterID, String extraFieldQuery, String sObjectName, String filteringField, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ' + extraFieldQuery;
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' , recordtype.developername From '+sObjectName+' where '+filteringField+' = \''+ filterID + '\' ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }

    private List<sObject> queryAll(ID filterID, String sObjectName, String filteringField, String extraQuery) {
    
        return queryAll( filterID, '',  sObjectName,  filteringField,  extraQuery) ;
    }
    
    public PageReference savePayment () {
        Pagereference ref;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        System.debug('Flag - Save Payment - isQuickSave:' + isQuickSaveStr);
        Boolean isQuickSave = (isQuickSaveStr==null)?false:Boolean.valueOf(isQuickSaveStr);
        
        Database.upsertResult[] upsertTarget;
        Database.deleteResult[] deleteTarget;

        Savepoint sp = Database.setSavepoint();
        try {
            user u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
            asi_mfm_prefix__c po_prefixes;
            List<asi_mfm_role_prefix_relationship__c> popx_list = new List<asi_mfm_role_prefix_relationship__c>();
            for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c, asi_mfm_prefix__r.name, asi_mfm_prefix__r.asi_mfm_module__c  from asi_mfm_role_prefix_relationship__c
            where asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = :u.asi_mfm_country__c
            AND asi_mfm_prefix__r.ASI_MFM_Inactive__c = false order by asi_mfm_prefix__r.name]) {
                if (px.asi_mfm_prefix__r.asi_mfm_module__c.contains('PO'))
                    popx_list.add(px);
            }      
            if (popx_list.size() == 0) {
                apexpages.message err = new apexpages.message(apexpages.severity.error, 'The user is not entitled to input POs');
                apexpages.addmessage(err); 
                Database.rollback(sp);
                return null;
            }
            else { 
                po_prefixes = popx_list[0].asi_mfm_prefix__r;

            }

            Set<ID> poHeaderToDeleteSet = new Set<ID>();
            List<ASI_MFM_PO__c> poHeaderToDeleteList = new List<ASI_MFM_PO__c>();
            
            for(ASI_MFM_Payment_Line_Item__c paymentLine : paymentLinesToDelete) {
                poHeaderToDeleteSet.add(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
            }

            for(ID poHeaderID : poHeaderToDeleteSet) {
                ASI_MFM_PO__c poHeader = new ASI_MFM_PO__c(ID = poHeaderID);
                poHeaderToDeleteList.add(poHeader);
            }

            if(paymentLinesToDelete.size()>0){
                deleteTarget = Database.delete(paymentLinesToDelete);
                delete poHeaderToDeleteList;
            }

            // One to one relationship between dummy poline and poheader
            List<ASI_MFM_PO_Line_Item__c> dummyPoLinesList = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO__c> dummyPoHeadersList = new List<ASI_MFM_PO__c>();

            List<ASI_MFM_Payment_Line_Item__c> upsertTargetList = new List<ASI_MFM_Payment_Line_Item__c>();
            for(String key : allPaymentLineMap.keySet()){
                ASI_MFM_Payment_Line_Item__c paymentLineItem = allPaymentLineMap.get(key).paymentLineItem;

                if(paymentLineItem.id == null) {
                    ASI_MFM_PO__c poDummyHeader = new ASI_MFM_PO__c(ASI_MFM_Prefix__c = po_prefixes.id, ASI_MFM_Return_Comments__c=key+'@@PoHeader', recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO__cASI_MFM_CAP_TH_PO'));
                    dummyPoHeadersList.add(poDummyHeader);
                }
            }

            Map<String, ASI_MFM_PO__c> poHeaderDummyMap = new Map<String, ASI_MFM_PO__c>();

            if(dummyPoHeadersList.size() > 0) {
                insert dummyPoHeadersList;
                for(ASI_MFM_PO__c poHeader : dummyPoHeadersList) {
                    poHeaderDummyMap.put(poHeader.ASI_MFM_Return_Comments__c, poHeader);
                }
            }

            for(String key : allPaymentLineMap.keySet()){
                ASI_MFM_Payment_Line_Item__c paymentLineItem = allPaymentLineMap.get(key).paymentLineItem;
                if(paymentLineItem.id == null && poHeaderDummyMap.containsKey(key+'@@PoHeader')) {
                    ASI_MFM_PO__c poHeader = poHeaderDummyMap.get(key+'@@PoHeader');
                    ASI_MFM_PO_Line_Item__c poDummyLine = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c=key+'@@PoLine', ASI_MFM_PO__c = poHeader.id, recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_PO_Line_Item__cASI_MFM_CAP_TH_PO_Line_Item'));
                    dummyPoLinesList.add(poDummyLine);
                }
            }

            Map<String, ASI_MFM_PO_Line_Item__c> poLineDummyMap = new Map<String, ASI_MFM_PO_Line_Item__c>();

            if(dummyPoLinesList.size() > 0) {
                insert dummyPoLinesList;
                for(ASI_MFM_PO_Line_Item__c poLine : dummyPoLinesList) {
                    poLineDummyMap.put(poLine.ASI_MFM_List_Item_Description__c, poLine);
                }
            }
            List<ASI_MFM_SKU_Code__c> sku_list = [SELECT id, ASI_MFM_Sub_brand__c from ASI_MFM_SKU_Code__c WHERE RecordType.DeveloperName LIKE '%TH%'];
            Map<id,id> sku_map = new Map<id,id>();
            for (ASI_MFM_SKU_Code__c sku: sku_list){
                sku_map.put(sku.id, sku.ASI_MFM_Sub_brand__c);
            }
            
            List<String> sortMapKey = new List<String>();
            for(String key : allPaymentLineMap.keySet()) {
                sortMapKey.add(key);
            }
            
            sortMapKey.sort();
            Boolean isError = false;
            for(String key : sortMapKey){
                ASI_MFM_Payment_Line_Item__c paymentLineItem = allPaymentLineMap.get(key).paymentLineItem;
                if(paymentLineItem.id == null) {
                    ASI_MFM_PO_Line_Item__c poLine = poLineDummyMap.get(key+'@@PoLine');
                    paymentLineItem.ASI_MFM_PO_Line_Item__c = poLine.id;
                }
                
                upsertTargetList.add(paymentLineItem);
            }
            
            if(isError) {
                upsertTargetList.clear();
                return null;
            }
                
            if(upsertTargetList.size()>0)
                upsertTarget = Database.upsert(upsertTargetList);

        }
        catch (DmlException ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,ex.getDmlMessage(0)));
            Database.rollback(sp);
            return null;
        }
        
        if (!isQuickSave){
            ref = new PageReference('/'+header.Id);
            ref.setRedirect(true);
        }
        else {
            isAllNull = false;
            isPaymentAmountNull = false;
            isQtyxVapAmountNotPayment = false;
        }
        return ref;
    }
    
    public void addPaymentLine () {
        
        string newIDCounter = newCounterCreator();
        ASI_MFM_Payment_Line_Item__c newPaymentLine = new ASI_MFM_Payment_Line_Item__c
                                    (
                                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_TH_Payment_Line_Item'),
                                        ASI_MFM_Payment__c = header.id,
                                        ASI_MFM_A_C_Code__c = defaultACCode.Id
                                    );
        paymentLineWrapper paymentLineWrap = new paymentLineWrapper(newPaymentLine, acSelectionList);
        allPaymentLineMap.put(PAYMENT_LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, paymentLineWrap);
        
    }
    
    public void clonePaymentLine () {

        string newIDCounter = newCounterCreator();
    
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_paymentLineID = params.get('PARAM_Payment_SOURCE_ITEM_ID');
        
        if (allPaymentLineMap.containsKey(param_paymentLineID)) {
        
            ASI_MFM_Payment_Line_Item__c PaymentLine = allPaymentLineMap.get(param_paymentLineID).paymentLineItem;
            ASI_MFM_Payment_Line_Item__c paymentLineClone = null;
            
            paymentLineClone = PaymentLine.clone(false, true, false, false);
            
            paymentLineWrapper paymentLineWrap = new paymentLineWrapper(paymentLineClone, acSelectionList);
            allPaymentLineMap.put(PAYMENT_LINE_ITEM_NEWRECORD_PREFIX+newIDCounter, paymentLineWrap);
        }
        
    }
    
    public void removePaymentLine () {
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_paymentLineID = params.get('PARAM_PAYMENT_LINE_ID');
        
        if (allPaymentLineMap.containsKey(param_paymentLineID)) {
            ASI_MFM_Payment_Line_Item__c PaymentLine = allPaymentLineMap.get(param_paymentLineID).paymentLineItem;
            allPaymentLineMap.remove(param_paymentLineID);
            if(!param_paymentLineID.contains(PAYMENT_LINE_ITEM_NEWRECORD_PREFIX)) {
                paymentLinesToDelete.add(PaymentLine);
            }
        }
        
        
    }
    
    public String newCounterCreator() {
    
        String idNew;
        IF(PAYMENT_LINE_ITEM_NEWRECORD_COUNTER == null) {
            PAYMENT_LINE_ITEM_NEWRECORD_COUNTER = 0;
        }
        else {
            PAYMENT_LINE_ITEM_NEWRECORD_COUNTER+=1;
        }
        
        String zParser = '';
        Integer oneDigitCounter = PAYMENT_LINE_ITEM_NEWRECORD_COUNTER;
        
        if(PAYMENT_LINE_ITEM_NEWRECORD_COUNTER > 9) {
            Integer zNumber = PAYMENT_LINE_ITEM_NEWRECORD_COUNTER/10;
            for (Integer i = 0; i < zNumber; i++) {
                zParser += 'z';
            }
            oneDigitCounter = Math.mod(PAYMENT_LINE_ITEM_NEWRECORD_COUNTER, 10);
        }
        
        idNew = zParser + string.valueof(oneDigitCounter);
        return idNew;
        
    }
    
    public PageReference cancel() {
        Pagereference ref;
        ref = new PageReference('/'+header.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    public void updateACPick() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String acChoice = params.get('ACChoice');
        String cpiKey = params.get('cpiKey');

        if(allPaymentLineMap.containsKey(cpiKey)){
            paymentLineWrapper paymentLineWrap = allPaymentLineMap.get(cpiKey);
            paymentLineWrap.ACSelected = acChoice;
            paymentLineWrap.updateAC();
        }
    }
    
    /*********************************
    Payment Line Wrapper
    *********************************/
    public class paymentLineWrapper {
        public ASI_MFM_Payment_Line_Item__c paymentLineItem {get;set;}
        public List<SelectOption> ACSelectOption {get;set;}
        public String ACSelected {get;set;}

        public paymentLineWrapper (ASI_MFM_Payment_Line_Item__c paymentLine, List<SelectOption> ACSelectOptionP) {
            this.ACSelectOption = ACSelectOptionP;
            this.paymentLineItem = paymentLine;
            this.ACSelected = (String)paymentLineItem.ASI_MFM_A_C_Code__c;
        }
        
        public void updateAC() {
            this.paymentLineItem.ASI_MFM_A_C_Code__c = (ACSelected != null && ACSelected != '' ) ? (ID)ACSelected : null;
        }
    
    }
      
}