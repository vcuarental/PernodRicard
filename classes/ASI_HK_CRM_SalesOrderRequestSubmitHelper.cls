public without sharing class ASI_HK_CRM_SalesOrderRequestSubmitHelper {
  
    private static final String STATUS_FINISH_SUBMIT = 'Waiting for Hold Code';
    private static List<WS_SF_Map> sfCurrencyToExternalMap = new List<WS_SF_Map>{
        new WS_SF_Map('HKD', 'HKD')
    };
    private static final String DEFAULT_UOM = 'BT';
    private static final List<WS_SF_Map> sfUOMToExternalMap = new List<WS_SF_Map>{
        new WS_SF_Map('Bottle', DEFAULT_UOM)
    };
    private static ASI_HK_CRM_Web_Service_Setting__c wsSetting;
    private static ASI_HK_CRM_SalesOrderManager.SalesOrderManagerHttpPort soWSManager;
    private static final Set<String> RTDEVNAMES_ACCT_FIXED_AMOUNT = ASI_HK_CRM_AccountGenerator.RTDEVNAME_ACCT_HAVE_CUST_PRICE;
    private static Map<Integer, ASI_MFM_SKU_Code__c> skuShortIdToSKUMap;
    //Edited by 20140603 Fixed SQL Query Limit
    public static Map<Id, ASI_MFM_SKU_Code__c> skuPackSizeMap;

    private List<ASI_HK_CRM_Sales_Order_Item__c> deleteSODetailList; 
    private List<ASI_HK_CRM_Sales_Order_Item__c> insertSODetailList;
    private List<ASI_HK_CRM_Sales_Order__c> updateSOList;
    private static final Map<Integer, String> monthMap = new Map<Integer, String>{
          1 => 'Jan'
        , 2 => 'Feb'
        , 3 => 'Mar'
        , 4 => 'Apr'
        , 5 => 'May'
        , 6 => 'Jun'
        , 7 => 'Jul'
        , 8 => 'Aug'
        , 9 => 'Sep' 
        , 10 => 'Oct'
        , 11 => 'Nov'
        , 12 => 'Dec'    
    };
    
    static {
        
        List<ASI_HK_CRM_Web_Service_Setting__c> wsSettings = [
            SELECT Id, ASI_HK_CRM_Base_URL__c, ASI_HK_CRM_Username__c, ASI_HK_CRM_Password__c
                , ASI_HK_CRM_SO_Processing_Version__c, ASI_HK_CRM_SO_Line_Item_Action_Type__c
            FROM ASI_HK_CRM_Web_Service_Setting__c
            WHERE ASI_HK_CRM_Key__c = 'ASI_HK_CRM_SalesOrderSubmit'
        ];
        if (wsSettings.size() == 1) {
            wsSetting = wsSettings[0];
            soWSManager = new ASI_HK_CRM_SalesOrderManager.SalesOrderManagerHttpPort(
                wsSetting.ASI_HK_CRM_Base_URL__c
                , wsSetting.ASI_HK_CRM_Username__c
                , wsSetting.ASI_HK_CRM_Password__c
            );
            soWSManager.timeout_x = 60000;
            skuShortIdToSKUMap = new Map<Integer, ASI_MFM_SKU_Code__c>();
            //Edited by 20140603 Fixed SQL Query Limit
            final String RTDEVNAME_SKU_DEFAULT = 'ASI_HK_CRM_SKU'; 
            skuPackSizeMap =  new Map<Id, ASI_MFM_SKU_Code__c>([select id,ASI_HK_CRM_Packaging_Size__c,ASI_HK_CRM_External_Short_ID__c from ASI_MFM_SKU_Code__c WHERE RecordType.DeveloperName = :RTDEVNAME_SKU_DEFAULT]);
            List<ASI_MFM_SKU_Code__c> skuList = [SELECT Id, ASI_HK_CRM_External_Short_ID__c FROM ASI_MFM_SKU_Code__c WHERE RecordType.DeveloperName = :RTDEVNAME_SKU_DEFAULT];
            for (ASI_MFM_SKU_Code__c sku : skuList) {
                if (sku.ASI_HK_CRM_External_Short_ID__c != null)
                    skuShortIdToSKUMap.put(sku.ASI_HK_CRM_External_Short_ID__c.intValue(), sku);
            }
        } else if (wsSettings.size() == 0) {
            //Check the custom object of ASI_HK_CRM_Web_Service_Setting__c
            System.debug('ASI HK CRM master web service setting not found');
        } else {
            System.debug('Duplicate ASI HK CRM master web service settings');
        } 
    }
    
    public static Set<String> requiredSOFields() {
        return new Set<String> {
            'Id'
            , 'ASI_HK_CRM_Cust_PO__c'
            , 'ASI_HK_CRM_Order_Date__c'
            , 'ASI_HK_CRM_Business_Unit__c'
            , 'CurrencyIsoCode'
            , 'ASI_HK_CRM_Delivery_Date__c'
            , 'ASI_HK_CRM_Owner_AD_Domain_User__c'
            , 'ASI_HK_CRM_Delivery_Remarks__c'
            , 'ASI_HK_CRM_Account_PA__c'
            , 'ASI_HK_CRM_Account_PA__r.ASI_HK_CRM_JDE_Account_Number__c'
            , 'ASI_HK_CRM_Account_PA__r.RecordTypeId'
            , 'ASI_HK_CRM_Account_PA__r.RecordType.DeveloperName'  
            , 'ASI_HK_CRM_Account_PA__r.Name'
            , 'ASI_HK_CRM_Customer_DA__c'
            , 'ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_JDE_Account_Number__c'
            , 'ASI_HK_CRM_Customer_DA__r.RecordTypeId'
            , 'ASI_HK_CRM_Customer_DA__r.RecordType.DeveloperName'
            , 'ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_JDE_Account_Number__c'
            , 'ASI_HK_CRM_Instruction_txt__c'
            , 'ASI_HK_CRM_Owner_Commission_Code__c' 
            , 'ASI_HK_CRM_User_D_O__c'
            , 'ASI_HK_CRM_SYS_PA_Acct_Type__c'
            , 'ASI_HK_CRM_Customer_DA__r.parentId'
            , 'ASI_HK_CRM_Customer_DA__r.recordType.name'
            , 'ASI_HK_CRM_Customer_DA__r.name'
            , 'ASI_HK_CRM_SO_External_ID__c'
            , 'ASI_HK_CRM_Attention__c'
            , 'Name'
            , 'OwnerId'
            , 'Owner.email'
            , 'ASI_HK_CRM_Payment_Method__c'
            
            //TODO Abel
        };
    }
    public static Set<String> requiredSODetailFields() {
        return new Set<String> {
            'Id'
            , 'ASI_HK_CRM_Quantity__c'
            , 'ASI_HK_CRM_UOM__c'
            , 'ASI_HK_CRM_Doc_Line_Num__c'
            , 'ASI_HK_CRM_SKU__c'
            , 'ASI_HK_CRM_SKU__r.ASI_MFM_SKU_Code__c'
            , 'ASI_HK_CRM_SKU__r.ASI_HK_CRM_External_Short_ID__c'
            , 'ASI_HK_CRM_Price__c'
            , 'ASI_HK_CRM_Amount__c'
            , 'ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c'
            , 'ASI_HK_CRM_SKU__r.ASI_HK_CRM_UOM1__c'
        };
    }
    
    public ASI_HK_CRM_SalesOrderRequestSubmitHelper() {
        deleteSODetailList = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        insertSODetailList = new List<ASI_HK_CRM_Sales_Order_Item__c>();
        updateSOList = new List<ASI_HK_CRM_Sales_Order__c>();
    }
    
    public void submitSO(ASI_HK_CRM_Sales_Order__c so) {
        if (soWSManager != null) {

            ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeader wsSOHeader = soToWSProcessSOHeader(so);
            if (wsSOHeader != null) {
                //return SO store the return of webService 
                ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSalesOrder returnSO = soWSManager.processSalesOrder(wsSOHeader);
                /*
                try{
                System.debug('adm1'+returnSO.e1MessageList.e1Messages[0]);
                }
                catch(exception e ){
                    System.debug('adm2'+returnSO.e1MessageList.e1Messages[0]);
                }
                */
                ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeader returnSOHeader = returnSO.header;                
                // TODO: Consider that user may edit the sales order during the waiting of web service response
                updateSOByWSConfirmSOHeaderToSO(so, returnSOHeader);
                so.ASI_HK_CRM_Order_Status_Name__c = STATUS_FINISH_SUBMIT;
                //Edit by Introv 20131206 added actual approver
                so.ASI_HK_CRM_Actual_Approve_User__c = UserInfo.getUserId();
                System.debug('kgb1'+returnSOHeader.detail);
                ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetail[] wsDetails = returnSOHeader.detail;
                List<ASI_HK_CRM_Sales_Order_Item__c> soDetails = new List<ASI_HK_CRM_Sales_Order_Item__c>();
                ID rtId = ASI_HK_CRM_SalesOrderDetailGenerator.getRecordTypeByDevName(ASI_HK_CRM_SalesOrderDetailGenerator.RT_Default).Id;
                for (ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetail wsDetail : wsDetails) {
                    ASI_HK_CRM_Sales_Order_Item__c soDetail = wsConfirmSODetailToSODetail(wsDetail);
                    soDetail.RecordTypeId = rtId;
                    soDetail.ASI_HK_CRM_Sales_Order__c = so.Id;
                    soDetails.add(soDetail);
                    System.debug('kgb2'+soDetail);
                }
                for (ASI_HK_CRM_Sales_Order_Item__c sod: soDetails){               
                    ASI_MFM_SKU_Code__c tempSku = skuPackSizeMap.get(sod.ASI_HK_CRM_SKU__c);
                    Decimal tempPackSize = tempSku != null ? tempSku.ASI_HK_CRM_Packaging_Size__c : null;
                    if (sod.ASI_HK_CRM_Price__c != null && tempPackSize != null && tempPackSize > 0)
                        sod.ASI_HK_CRM_Price__c = sod.ASI_HK_CRM_Price__c/tempPackSize;
                }
                
                // TODO: Only update the existing SO detail because no split items are returned in first request
                deleteSODetailList.addAll(so.ASI_HK_CRM_Sales_Order_Request_Items__r);
                insertSODetailList.addAll(soDetails);
                updateSOList.add(so);
            } else {
                System.debug('Invalid Sales Order: ' + String.valueOf(so));
            }
        } else {
            System.debug('Skip submitting Sales Order: ' + String.valueOf(so));
        }
        //return true;
        
    }
    
    public void commitChanges() {
        delete deleteSODetailList;
        insert insertSODetailList;
        update updateSOList;
    }
    
    private static ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeader soToWSProcessSOHeader(ASI_HK_CRM_Sales_Order__c so) {
        if (so == null) return null;        
        
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeader result = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeader();
        
        result.customerPO = so.ASI_HK_CRM_Cust_PO__c;
        result.dateOrdered = Datetime.newInstanceGmt(so.ASI_HK_CRM_Order_Date__c, Time.newInstance(0, 0, 0, 0));
        result.businessUnit = so.ASI_HK_CRM_Business_Unit__c;
        result.currencyCodeTo = so.CurrencyIsoCode != null ? (String)searchValue(sfCurrencyToExternalMap, so.CurrencyIsoCode, false) : null;
        result.dateRequested = Datetime.newInstanceGmt(so.ASI_HK_CRM_Delivery_Date__c, Time.newInstance(0, 0, 0, 0));
        String adDomainName = so.ASI_HK_CRM_Owner_AD_Domain_User__c;
        if (!String.isBlank(adDomainName)) {
            result.orderedBy = adDomainName.contains('\\') ? adDomainName.substringAfter('\\') : adDomainName;
        }
        //result.attachmentText = so.ASI_HK_CRM_Delivery_Remarks__c;  No longer need because JDE 60 chars
        System.debug('so ext 6'+ result.attachmentText);
        // processing
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeaderProcessing soProcessing = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeaderProcessing();
        result.processing = soProcessing;
        soProcessing.processingVersion = wsSetting.ASI_HK_CRM_SO_Processing_Version__c;
        soProcessing.actionType = 'A';
        // detail
        List<ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetail> wsDetails = new List<ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetail>();
        result.detail = wsDetails;
        List<ASI_HK_CRM_Sales_Order_Item__c> soDetails = so.ASI_HK_CRM_Sales_Order_Request_Items__r;
        for (ASI_HK_CRM_Sales_Order_Item__c soDetail : soDetails) {
            wsDetails.add(soDetailToWSProcessSODetail(so, soDetail));
        }
        // soldTo / shipTo
        if (so.ASI_HK_CRM_Customer_DA__c != null){ 
            //Cash Account
            //if (so.ASI_HK_CRM_Customer_DA__r.recordType.name == 'Outlet (HK)' ){
            System.debug('abk7' +so.ASI_HK_CRM_Customer_DA__r.recordType.developerName );
            if ((so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_HK_CRM_Outlet' //CR 201311
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_First_Contact'
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Second_Contact'
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Potential'
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Second_Contact_Le_Cercle_Locked')
                && so.ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_JDE_Account_Number__c != null){  
                
                System.debug('abk8'+so.ASI_HK_CRM_Customer_DA__c + 'JDE No' + so.ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_JDE_Account_Number__c);
                
                result.shipTo = so.ASI_HK_CRM_Customer_DA__c != null ? acctToWSProcessSOCustomer(so.ASI_HK_CRM_Customer_DA__r) : null;
                result.soldTo = so.ASI_HK_CRM_Customer_DA__c != null ? acctToWSProcessSOCustomer(so.ASI_HK_CRM_Customer_DA__r) : null;
            }
            //Luxury Account without JDE Number
            
            else if(so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_First_Contact' 
                    || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Second_Contact'
                    || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Potential'
                    || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Second_Contact_Le_Cercle_Locked'){
                if(so.ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_JDE_Account_Number__c != null){
                
                }else{
                    System.debug('abk9'+so.ASI_HK_CRM_Account_PA__c + 'JDE No' + so.ASI_HK_CRM_Account_PA__r.ASI_HK_CRM_JDE_Account_Number__c);
                    result.shipTo = so.ASI_HK_CRM_Account_PA__c != null ? acctToWSProcessSOCustomer(so.ASI_HK_CRM_Account_PA__r) : null;
                    result.soldTo = so.ASI_HK_CRM_Account_PA__c != null ? acctToWSProcessSOCustomer(so.ASI_HK_CRM_Account_PA__r) : null;
                }            
            }
            
            //Other Account(Potential Account)
            else{
                System.debug('abk10'+so.ASI_HK_CRM_Account_PA__c);
                result.shipTo = so.ASI_HK_CRM_Account_PA__c != null ? acctToWSProcessSOCustomer(so.ASI_HK_CRM_Account_PA__r) : null;
                result.soldTo = so.ASI_HK_CRM_Account_PA__c != null ? acctToWSProcessSOCustomer(so.ASI_HK_CRM_Account_PA__r) : null;
            }
        }
        
        System.debug('abk1 soldTo 1 '+result.shipTo);
        System.debug('abk shipTo'+result.shipTO);
        // if ( result.shipTo == null ) result.shipTo = result.soldTo;
        
        if ( so.ASI_HK_CRM_Customer_DA__c != null ){
            System.debug('abk4 true');
        } 
        System.debug('abk2 shipTo'+result.shipTo);
        // billing
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeaderBilling wsBilling = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeaderBilling();
        result.billing = wsBilling;
        wsBilling.deliveryInstruction1 = so.ASI_HK_CRM_Instruction_txt__c;
        String deliveryInstruction2 = '';
        if (so.ASI_HK_CRM_Delivery_Date__c != null) deliveryInstruction2 += dateToMon(so.ASI_HK_CRM_Delivery_Date__c); 
        if (so.ASI_HK_CRM_Attention__c != null) deliveryInstruction2 += ' \\ ' + so.ASI_HK_CRM_Attention__c;
        wsBilling.deliveryInstruction2 = deliveryInstruction2;
        System.debug('gab deliveryInstructin2'+deliveryInstruction2); 
        wsBilling.creditCardAccountNumber = so.ASI_HK_CRM_Cust_PO__c;
        wsBilling.creditCardAccountName = 'P';    //Abel

        // billing > carrier
        ASI_HK_CRM_SalesOrderManagerTypes.Entity wsCarrier = new ASI_HK_CRM_SalesOrderManagerTypes.Entity();
        wsBilling.carrier = wsCarrier;
        wsCarrier.entityId = so.ASI_HK_CRM_Owner_Commission_Code__c != null ? so.ASI_HK_CRM_Owner_Commission_Code__c : null;
        // userReservedData
        ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData wsUserResvData = new ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData();
        result.userReservedData = wsUserResvData;
        if (so.ASI_HK_CRM_User_D_O__c) wsUserResvData.userReservedCode = 'Y';
        else wsUserResvData.userReservedCode = 'N';
        System.debug('pop4'+wsUserResvData.userReservedCode);
        //wsUserResvData.userReservedReference = ((String)so.Id).substring(0, 15);
        wsUserResvData.userReservedReference = ((String)so.ASI_HK_CRM_SO_External_ID__c);
        if (so.ASI_HK_CRM_Payment_Method__c!=null && (so.ASI_HK_CRM_Payment_Method__c.equalsignoreCase('CASH') || so.ASI_HK_CRM_Payment_Method__c.equalsignoreCase('CHQ') || so.ASI_HK_CRM_Payment_Method__c.equalsignoreCase('PAID')))
            wsUserResvData.userReservedNumber=777;

        System.debug('so ext1'+ wsUserResvData.userReservedReference);
        //Add By Abel
        System.debug('so ext3'+String.valueOf(DateTime.now()));
        //wsUserResvData.userReservedDate = '2013-06-18T00:00:00.000+08:00';
        wsUserResvData.userReservedDate = DateTime.now().format('yyyy-MM-dd')+'T00:00:00.000+08:00';
        System.debug('so ext 4'+wsUserResvData.userReservedDate);
        return result;
    }
    
    private static ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetail soDetailToWSProcessSODetail(ASI_HK_CRM_Sales_Order__c so, ASI_HK_CRM_Sales_Order_Item__c soDetail) {
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetail result = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetail();
        
        result.quantityOrdered = soDetail.ASI_HK_CRM_Quantity__c;
        //result.unitOfMeasureCodeTransaction = soDetail.ASI_HK_CRM_UOM__c != null ? (String)searchValue(sfUOMToExternalMap, soDetail.ASI_HK_CRM_UOM__c, false) : DEFAULT_UOM;
        result.unitOfMeasureCodeTransaction = soDetail.ASI_HK_CRM_SKU__r.ASI_HK_CRM_UOM1__c;
        result.documentLineNumber = soDetail.ASI_HK_CRM_Doc_Line_Num__c;
        result.reference = so.ASI_HK_CRM_Cust_PO__c;
        //UserReservedCode
        ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData wsDetailUserReservedData = new ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData();
        result.userReservedData = wsDetailUserReservedData;
        if (so.ASI_HK_CRM_User_D_O__c) {
            wsDetailUserReservedData.userReservedCode = 'Y';
        }else { wsDetailUserReservedData.userReservedCode = 'N'; }
        System.debug('pop8'+wsDetailUserReservedData.userReservedCode);
        // product
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailProduct pd = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailProduct();
        result.product = pd;
        // product > item
        ASI_HK_CRM_SalesOrderManagerTypes.ItemGroupCustomer igCust = new ASI_HK_CRM_SalesOrderManagerTypes.ItemGroupCustomer();
        pd.item = igCust;
        igCust.itemProduct = soDetail.ASI_HK_CRM_SKU__r.ASI_MFM_SKU_Code__c;
        System.debug('lab1'+soDetail.ASI_HK_CRM_SKU__r.ASI_MFM_SKU_Code__c);
        igCust.itemId = soDetail.ASI_HK_CRM_SKU__r.ASI_HK_CRM_External_Short_ID__c.intValue();
        System.debug('lab2');
        // billing
        if (RTDEVNAMES_ACCT_FIXED_AMOUNT.contains(so.ASI_HK_CRM_Account_PA__r.RecordType.DeveloperName)) {
            ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailBilling wsBilling = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailBilling();
            result.billing = wsBilling;
            // billing > pricing
            ASI_HK_CRM_SalesOrderManagerTypes.Pricing wsPricing = new ASI_HK_CRM_SalesOrderManagerTypes.Pricing();
            wsBilling.pricing = wsPricing;
            //TODO Abel fix credit account assign null value I have change to null
            System.debug('bdk packaging size '+soDetail.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c);
            //if ( so.ASI_HK_CRM_Customer_DA__r.recordType.name == 'outlet (HK)' ){
            if ( (so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_HK_CRM_Outlet'  //CR 201311
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_First_Contact'
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Second_Contact'
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Potential'
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Second_Contact_Le_Cercle_Locked')
                && so.ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_JDE_Account_Number__c != null){  
                wsPricing.priceUnitDomestic = null;
                wsPricing.priceExtendedDomestic = null;
                System.debug('pop2'+wsPricing.priceUnitDomestic);
            }
            //TODO luxury 2 record type
            else 
            {   
                wsPricing.priceUnitDomestic = soDetail.ASI_HK_CRM_Price__c*soDetail.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c;
                System.debug('pop3'+soDetail.ASI_HK_CRM_Price__c);
            }
            /*
            else{
                wsPricing.priceUnitDomestic = soDetail.ASI_HK_CRM_Price__c;
                System.debug('pop3'+soDetail.ASI_HK_CRM_Price__c);
                //wsPricing.priceExtendedDomestic = soDetail.ASI_HK_CRM_Amount__c;               //Abel 20130806
                System.debug('pop');
            }
            */
            // billing > carrier
            ASI_HK_CRM_SalesOrderManagerTypes.Entity wsCarrier = new ASI_HK_CRM_SalesOrderManagerTypes.Entity();
            wsBilling.carrier = wsCarrier;
            wsCarrier.entityId = so.ASI_HK_CRM_Owner_Commission_Code__c != null ? so.ASI_HK_CRM_Owner_Commission_Code__c : null;
        }
        
        //////////////////////////TODO Duplicate the upper
        else{
            ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailBilling wsBilling = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailBilling();
            result.billing = wsBilling;
            // billing > pricing
            ASI_HK_CRM_SalesOrderManagerTypes.Pricing wsPricing = new ASI_HK_CRM_SalesOrderManagerTypes.Pricing();
            wsBilling.pricing = wsPricing;
            //TODO Abel fix credit account assign null value I have change to null
            System.debug('bdk packaging size '+soDetail.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c);
            //if ( so.ASI_HK_CRM_Customer_DA__r.recordType.name == 'outlet (HK)' ){
            if ( (so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_HK_CRM_Outlet'  //CR 201311
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_First_Contact'
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Second_Contact'
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Potential'
                || so.ASI_HK_CRM_Customer_DA__r.recordType.developerName == 'ASI_Luxury_Account_HK_Second_Contact_Le_Cercle_Locked') 
                && so.ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_JDE_Account_Number__c != null){  
                wsPricing.priceUnitDomestic = null;
                wsPricing.priceExtendedDomestic = null;
                System.debug('pop2'+wsPricing.priceUnitDomestic);
            }
            //TODO luxury 2 record type
            else //( so.ASI_HK_CRM_Customer_DA__r.recordType.name == 'Potential Account - Prestige (HK)' || so.ASI_HK_CRM_Customer_DA__r.recordType.name == 'Potential Account (HK)'){
            {   
                wsPricing.priceUnitDomestic = soDetail.ASI_HK_CRM_Price__c*soDetail.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c;
                System.debug('pop3'+soDetail.ASI_HK_CRM_Price__c);
            }
            /*
            else{
                wsPricing.priceUnitDomestic = soDetail.ASI_HK_CRM_Price__c;
                System.debug('pop3'+soDetail.ASI_HK_CRM_Price__c);
                //wsPricing.priceExtendedDomestic = soDetail.ASI_HK_CRM_Amount__c;               //Abel 20130806
                System.debug('pop');
            }
            */
            // billing > carrier
            ASI_HK_CRM_SalesOrderManagerTypes.Entity wsCarrier = new ASI_HK_CRM_SalesOrderManagerTypes.Entity();
            wsBilling.carrier = wsCarrier;
            wsCarrier.entityId = so.ASI_HK_CRM_Owner_Commission_Code__c != null ? so.ASI_HK_CRM_Owner_Commission_Code__c : null;
        }
        //////////////////////////TODO
        // processing
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailProcessing soDetailProcessing = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailProcessing();
        result.processing = soDetailProcessing;
        soDetailProcessing.actionType = wsSetting.ASI_HK_CRM_SO_Line_Item_Action_Type__c;
        // userReservedData
        ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData wsUserResvData = new ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData();
        result.userReservedData = wsUserResvData;
        wsUserResvData.userReservedAmount = soDetail.ASI_HK_CRM_Price__c;
        wsUserResvData.userReservedDate = DateTime.now().format('yyyy-MM-dd')+'T00:00:00.000+08:00';
        //wsUserResvData.userReservedDate = '2013-06-18T00:00:00.000+08:00';
        if (so.ASI_HK_CRM_User_D_O__c) {
            wsUserResvData.userReservedCode = 'Y';
        }else { wsUserResvData.userReservedCode = 'N'; }
        System.debug('pop5'+wsUserResvData.userReservedCode); 
        //wsUserResvData.userReservedCode = '';
        //wsUserResvData.userReservedCode = String.valueOf(so.ASI_HK_CRM_User_D_O__c);
        wsUserResvData.userReservedReference = ((String)soDetail.Id).substring(0, 15);
        
        return result;
    }
    
    private static ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOCustomer acctToWSProcessSOCustomer(Account acct) {
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOCustomer result = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOCustomer();
        
        ASI_HK_CRM_SalesOrderManagerTypes.Entity entity = new ASI_HK_CRM_SalesOrderManagerTypes.Entity();
        entity.entityId = acct.ASI_HK_CRM_JDE_Account_Number__c != null ? acct.ASI_HK_CRM_JDE_Account_Number__c : null;
        System.debug('abk888888888888888888'+entity.entityId);
        result.customer = entity;
        
        return result;
    }
    
    private static void updateSOByWSConfirmSOHeaderToSO(ASI_HK_CRM_Sales_Order__c so, ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeader wsHeader) {
        if (wsHeader.customerPO != null) so.ASI_HK_CRM_Cust_PO__c = wsHeader.customerPO;
        ASI_HK_CRM_SalesOrderManagerTypes.SalesOrderKey soKey = wsHeader.salesOrderKey;
        if (soKey != null) {
            so.ASI_HK_CRM_Code__c = String.valueOf(soKey.documentNumber);
            so.ASI_HK_CRM_SYS_DocumentCompany__c = soKey.documentCompany;
            so.ASI_HK_CRM_JDE_Order_Type_Code__c = soKey.documentTypeCode;
            so.ASI_HK_CRM_JDE_Order_No__c = String.valueOf(soKey.documentNumber);
        }
    }
    
    private static ASI_HK_CRM_Sales_Order_Item__c wsConfirmSODetailToSODetail(ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetail wsDetail) {
        ASI_HK_CRM_Sales_Order_Item__c result = new ASI_HK_CRM_Sales_Order_Item__c();
        
        result.ASI_HK_CRM_Doc_Line_Num__c = wsDetail.documentLineNumber;
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailProduct pd = wsDetail.product;
        if (pd != null) {
            result.ASI_HK_CRM_SYS_StatusCodeLast__c = pd.statusCodeLast;
            result.ASI_HK_CRM_SYS_StatusCodeLast__c = pd.statusCodeNext;
            ASI_HK_CRM_SalesOrderManagerTypes.ItemGroupCustomer pdItem = wsDetail.product.item;
            if (pdItem != null) {
                result.ASI_HK_CRM_SKU__c = skuShortIdToSKUMap.get(pdItem.itemId).Id;
            }
        }
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailFinancial wsFinancial = wsDetail.financial;
        if (wsFinancial != null) {
            //result.ASI_HK_CRM_Price__c = wsFinancial.priceExtendedDomestic;    //Abel
            System.debug('bdk1'+wsFinancial.priceExtendedDomestic);
            System.debug('bdk2');
            //System.debug('bdk3 priceUnitDomestic'+)
            result.ASI_HK_CRM_Price__c = wsFinancial.priceUnitDomestic; 
            //System.debug('bdk4 sku num'+result.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c);
            //Decimal tempNum = result.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c;
            //result.ASI_HK_CRM_Price__c = result.ASI_HK_CRM_Price__c/tempNum;
            System.debug('bdk3 priceUnitDomestic'+wsFinancial.priceUnitDomestic);
            result.CurrencyIsoCode = 'HKD';
        }
        ASI_HK_CRM_SalesOrderManagerTypes.Quantity wsQuantity = wsDetail.quantity;
        if (wsQuantity != null) {
            result.ASI_HK_CRM_Quantity__c = wsQuantity.quantityOrdered;
            result.ASI_HK_CRM_UOM__c = (String)searchValue(sfUOMToExternalMap, wsQuantity.unitOfMeasureCodeTransaction, true);
        }
        
        return result;
    }
        
    private static Object searchValue(List<WS_SF_Map> theMapList, Object key, Boolean isReversed) {
        if (theMapList != null) {
            for (WS_SF_Map theMap : theMapList) {
                if (isReversed != true && theMap.wsValue == key) {
                    return theMap.sfValue;
                } else if (isReversed == true && theMap.sfValue == key) {
                    return theMap.wsValue;
                }
            }
        }
        return null;
    }
    
    public class WS_SF_Map {
        public Object wsValue;
        public Object sfValue;
        
        public WS_SF_Map(Object wsValue, Object sfValue) {
            this.wsValue = wsValue;
            this.sfValue = sfValue;
        }
    }
    
    public static String dateToMon(Date inputDate){
        String result = '';
        String year = String.valueOf(inputDate.year());
        String month = monthMap.get(inputDate.month());
        String day = String.valueOf(inputDate.day());
        result = day + ' ' + month + ' ' + year; 
        return  result;
    }
    
}