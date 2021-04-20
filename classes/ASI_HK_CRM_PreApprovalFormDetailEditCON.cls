// 20151130 - modified the channel definition - 13*
public with sharing class ASI_HK_CRM_PreApprovalFormDetailEditCON {

    private static final String RTDEVNAME_SKU = ASI_HK_CRM_SKUGenerator.RT_Default;
    private static final String RTDEVNAME_SB = ASI_HK_CRM_SubBrandGenerator.RT_Default;
    private static final String RTDEVNAME_CUST_PD_PRICE = ASI_HK_CRM_CustomerProductPriceGenerator.RT_Default;
    private static String MTYPE_FOC_STATIC = 'foc';
    private static String MTYPE_FOC_BULK_STATIC = 'foc_bulk';
    private static String MTYPE_VARIABLE_STATIC = 'variable';
    private static String MTYPE_FIXED_STATIC = 'fixed';
    private static String MTYPE_FIXED_BOTTLE_STATIC = 'fixed_bottle';
    private static final Map<String, String> MECHANIC_TO_BASE_TYPE = new Map<String, String> {
        'PAF Item - FOC' => 'foc'
        , 'PAF Item - FOC Bulk' => 'foc_bulk'
        , 'PAF Item - Variable' => 'variable'
        , 'PAF Item - Fixed Amount' => 'fixed'
        , 'PAF Item - Fixed Bottle' => 'fixed_bottle'
    };
    private static final Set<String> STATUS_ALLOW_EDIT = new Set<String>{
        'Draft'
        , 'SA Rejected'
        , 'FD Rejected'
        , 'FM Rejected'
        , 'MD Rejected'
        , 'MKTD Rejected'
        , 'HS Rejected'
        , 'Supervisor Rejected'
    };
    private static final list<list<string>> mechanicOrder = new list<list<String>>{
        new list<String>{'A01', 'A08'},
        new list<String>{'A02', 'A04', 'A07'},
        new list<String>{'A17', 'A09', 'A06', 'A12', 'A14', 'B01'},
        new list<String>{'B03', 'B02', 'B07', 'B05', 'B06'},
        new list<String>{'B08', 'B09', 'B04', 'B10', 'B11'}
    };
    private static Map<String, List<String>> mechanicOptionMap;
    public String MTYPE_FOC { get { return MTYPE_FOC_STATIC; } private set; }
    public String MTYPE_FOC_BULK { get { return MTYPE_FOC_BULK_STATIC; } private set; }
    public String MTYPE_VARIABLE { get { return MTYPE_VARIABLE_STATIC; } private set; }
    public String MTYPE_FIXED { get { return MTYPE_FIXED_STATIC; } private set; }
    public String MTYPE_FIXED_BOTTLE { get { return MTYPE_FIXED_BOTTLE_STATIC; } private set; }
    public ID headerId { get; private set; }
    public ID custId { get; private set; }
    public String pageTitle { get; private set; }
    public Boolean allowEdit { get; private set; }
    public Boolean allowPouring { get; private set; }{allowPouring=false;}
    public Boolean isKeyAccount { get; private set; } //20180803, Added by Introv Kelvin
    public List<List<String>> sbSearchOptions { get; set; }
    public List<List<String>> mechanicOptions { get; set; }
    public List<List<String>> mechanicNames { get; set; }
    private static Map<Id, ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mechanicMap = new Map<Id, ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();
    private static Map<id, decimal> ChannelReferencePriceMap = new Map<Id, decimal>();
    private static Map<id, decimal> CustomerReferencePriceMap = new Map<Id, decimal>();
    private static String allPrdtName {get;set;} //20160318, added by Leo
    private static Decimal totalQty = 0; //20160413, added by Leo
    private static Decimal totalDistcountBT =0; 
    private static Decimal totalSalesVal = 0; //20160413, added by Leo
    private static Set<Id> lineItemSet = new Set<Id>(); //20160413, added by Leo
    private static Set<String> allPrdtSet = new Set<String>(); //20160413, added by Leo
    private static Map<Id, decimal> skuDiscountMapOnInvoice_bt = new Map<Id, decimal>();
    private static Map<Id, decimal> skuDiscountMapRebate_bt = new Map<Id, decimal>();
    
    private static Decimal totalDiscountRate =0;
    
    static{
        for (ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mec : [select id, Name, ASI_CRM_Short_Name__c, ASI_HK_CRM_Code__c from ASI_HK_CRM_Pre_Approval_Form_Mechanic__c WHERE ASI_CRM_HK_Active__c = true])
        {
            System.debug('payk22'+mec.Name);
            mechanicMap.put(mec.id, mec);
        }
        allPrdtName = [SELECT Name FROM ASI_CRM_HK_PAF_All_Product__c WHERE ASI_CRM_HK_isActive__c = TRUE limit 1].Name;        
    }            
    
    public ASI_HK_CRM_PreApprovalFormDetailEditCON(ApexPages.StandardSetController stdSetCon) {
        this.headerId = ApexPages.currentPage().getParameters().get('id');
        ASI_HK_CRM_Pre_Approval_Form__c header = [SELECT Id, ASI_HK_CRM_PAF_Customer__c, ASI_HK_CRM_PAF_Customer__r.Name, ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c , ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c, ASI_HK_CRM_PAF_Status__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE Id = :headerId];
        this.custId = header.ASI_HK_CRM_PAF_Customer__c;
        this.pageTitle = header.ASI_HK_CRM_PAF_Customer__c != null ? header.ASI_HK_CRM_PAF_Customer__r.Name : null;
        this.allowEdit = header.ASI_HK_CRM_PAF_Status__c != null && STATUS_ALLOW_EDIT.contains(header.ASI_HK_CRM_PAF_Status__c);
        this.isKeyAccount = header.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c == NULL? FALSE : header.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Type__c.startsWith('9'); //20180803, Added by Introv Kelvin
        
        for(ASI_CRM_CN_Channel__c channel : [select id,Name,ASI_CRM_Allow_Pouring__c  from ASI_CRM_CN_Channel__c where recordType.developerName ='ASI_CRM_HK_Channel']){
            system.debug(header.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c + 'channel: ' + channel.Name);
            if(header.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c!=null && header.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c == channel.Name && channel.ASI_CRM_Allow_Pouring__c){
                allowPouring=true;
            }
        }
         
        //
        //if (this.allowEdit != true) {
        //    showPageError('You are not allowed to edit the line items for current status');
        //}

        this.sbSearchOptions = getSubBrandSearchOptions();
        this.mechanicOptions = getMechanicOptions();  //Comment By Abel
        getMechanicNames();
        //TODO ABEL sorting
        
        //Map<String, List<String>> orderMechanicMap = new Map<String, List<String>>();   
        //List<String> orderKeyStr = new List<String>();
        //List<List<String>> tempMechanic = getMechanicOptions().values
        
        //for( Integer i = 0; i < tempMechanic.size(); i++) {
        //    orderKeyStr.add(tempMechanic.get(i).get(1));
        //    orderMechanicMap.put(tempMechanic.get(i).get(1),tempMechanic.get(i));
        //}
        //orderKeyStr.sort();
        
        //for( String str1: orderKeyStr ) {
        //    this.mechanicOptions.add(orderMechanicMap.get(str1));
        //}
        
        //Abel sorting
        
    }
    private void getMechanicNames(){
        mechanicNames = new list<list<String>>();
        Integer i = 0;
        for(list<String> order : mechanicOrder){
            for(String s : order){
                for(list<String> options : mechanicOptions){
                    if(options[3] == s){
                        if(mechanicNames.size() <= i){
                            mechanicNames.add(new list<String>());
                        }
                        list<String> names = mechanicNames[i];
                        String des = '';
                        if(options[2] == 'variable'){
                            des = '</br>Disc % or $ per BT';
                        }else if(options[2] == 'foc'){
                            des = '</br>Buy BT / Free BT';
                        }else if(options[2] == 'fixed_bottle'){
                            des = '</br>Fixed BT';
                        }else if(options[2] == 'fixed'){
                            des = '</br>Fixed $';
                        }else if(options[2] == 'foc_bulk'){
                            des = '</br>Buy BT / Fixed BT';
                        }
                        names.add(options[5]+des);
                        break;
                    }
                }
            }
            i++;
        }
    }
    @RemoteAction
    public static List<ASI_HK_CRM_PAFLineItem> lineItemList(ID headerId) {
        List<ASI_HK_CRM_PAFLineItem> result = new List<ASI_HK_CRM_PAFLineItem>();
        List<ASI_HK_CRM_Pre_Approval_Form__c> pafList = [
            SELECT Id, ASI_HK_CRM_PAF_Customer__c, ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c
            FROM ASI_HK_CRM_Pre_Approval_Form__c
            WHERE Id = :headerId
        ];
        system.debug('Header ID'+headerId);
        system.debug('pafList[0].ASI_HK_CRM_PAF_Customer__c:   '+pafList[0].ASI_HK_CRM_PAF_Customer__c);
        if (pafList[0].ASI_HK_CRM_PAF_Customer__c != null){
            Account acct = [SELECT Id, ASI_HK_CRM_Customer_Number__c, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Channel__c, ASI_HK_CRM_Customer_Type__c 
                            //, ASI_CRM_AccountAdditionalField__pr.ASI_CRM_Pricing_Channel__c
                            FROM Account 
                            WHERE Id = :pafList[0].ASI_HK_CRM_PAF_Customer__c];
            
            //20160406, added by Leo
            string accChannel = acct.ASI_HK_CRM_Channel__c.substring(0,3) + '%';
            
            ASI_HK_CRM_Channel_Local_Channel_Map__c PricingChannelMap = [SELECT ASI_HK_CRM_Channel__c, ASI_HK_CRM_Pricing_Channel__c 
                                                                         From ASI_HK_CRM_Channel_Local_Channel_Map__c
                                                                         Where ASI_HK_CRM_Channel__c Like: accChannel
                                                                         Limit 1];
            
            string pricingChannel = '';
            if (PricingChannelMap.ASI_HK_CRM_Pricing_Channel__c != null)
                pricingChannel = PricingChannelMap.ASI_HK_CRM_Pricing_Channel__c;
            //20160406, added by Leo
    
            List<ASI_HK_CRM_Customer_Product_Price__c> ChannelBasePrice = [select ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_Bottle_Price__c FROM ASI_HK_CRM_Customer_Product_Price__c 
                                                                           WHERE 
                                                                           //(ASI_CRM_HK_Channel__c = :acct.ASI_HK_CRM_Channel__c Or
                                                                           ASI_CRM_HK_Channel__c =: pricingChannel //20160406, added by Leo
                                                                            //      OR ASI_CRM_HK_Channel__c =: subStringChannel
                                                                            //     )
                                                                           AND //20160406, added by Leo
                                                                           recordtype.developername = 'ASI_CRM_HK_Channel_PAF_Price'];
            System.debug('Line ItemChannelBasePrice List Size Before=======' + ChannelBasePrice.size());
            for (ASI_HK_CRM_Customer_Product_Price__c channelprice : ChannelBasePrice) {
                ChannelReferencePriceMap.put(channelprice.ASI_HK_CRM_SKU_Lookup__c, channelprice.ASI_HK_CRM_Bottle_Price__c);
            //  System.debug(channelprice.ASI_HK_CRM_SKU_Lookup__c + '=========:' + channelprice.ASI_HK_CRM_Bottle_Price__c);
            }
            system.debug('Line Item ChannelBasePrice List Size After=======' + ChannelReferencePriceMap);
            List<ASI_HK_CRM_Customer_Product_Price__c> CustomerBasePrice = [select ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_Bottle_Price__c FROM ASI_HK_CRM_Customer_Product_Price__c WHERE ASI_HK_CRM_Customer_Name__c =:pafList[0].ASI_HK_CRM_PAF_Customer__c AND recordtype.developername = 'ASI_CRM_HK_Customer_PAF_Price'];
            for (ASI_HK_CRM_Customer_Product_Price__c cusprice : CustomerBasePrice) {
                CustomerReferencePriceMap.put(cusprice.ASI_HK_CRM_SKU_Lookup__c, cusprice.ASI_HK_CRM_Bottle_Price__c);
            }
                    
            ASI_HK_CRM_Pre_Approval_Form__c paf = pafList.size() > 0 ? pafList[0] : null;
            List<ASI_HK_CRM_Pre_Approval_Form_Item__c> lineItems = [
                SELECT Id, Name, ASI_HK_CRM_Pre_Approval_Form_Lookup__c, ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_SKU_Lookup__r.Name, ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Benchmark__c
                    , ASI_HK_CRM_Mechanic__c, ASI_HK_CRM_Mechanic__r.Name, ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c, ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c
                    , ASI_HK_CRM_Target_Volume_Qty__c, ASI_HK_CRM_Price__c, ASI_HK_CRM_Pouring__c
                    , ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c, ASI_HK_CRM_FOC_Free_Bottle_Option_1__c
                    , ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c, ASI_HK_CRM_FOC_Free_Bottle_Option_2__c
                    , ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c, ASI_HK_CRM_FOC_Free_Bottle_Option_3__c
                    , ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c, ASI_HK_CRM_FOC_Free_Bottle_Option_4__c
                    , ASI_HK_CRM_Rebate_Disc_Percent__c, ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c, ASI_HK_CRM_Fixed_Amount__c
                    , ASI_HK_CRM_Fixed_Bottle__c
                    , ASI_HK_CRM_Investment_Value__c
                    , ASI_HK_CRM_Conditions_for_Payment__c
                    , ASI_CRM_HK_Pricing_Item__c
                    //, ASI_HK_CRM_SKU_Lookup__r.ASI_CRM_HK_All_Product__c //20160317, added by Leo
                FROM ASI_HK_CRM_Pre_Approval_Form_Item__c
                WHERE ASI_HK_CRM_Pre_Approval_Form_Lookup__c = :headerId
                ORDER BY ASI_HK_CRM_SKU_Lookup__r.Name, ASI_HK_CRM_Mechanic__r.name
            ];
            Map<ID, Decimal> sbIdToBMMap = null;
            if (paf != null) {
                String localChannel = paf.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Local_Channel__c;
                if (String.isBlank(localChannel)) {
                    localChannel = localChannelByChannel(paf.ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Channel__c);
                }
                sbIdToBMMap = sbIdToInvestmentBenchmarkMap(localChannel);
            }
            
            for (ASI_HK_CRM_Pre_Approval_Form_Item__c li : lineItems) {
                ASI_HK_CRM_PAFLineItem tempLi = new ASI_HK_CRM_PAFLineItem();
                tempLi.id = li.Id;
                tempLi.skuId = li.ASI_HK_CRM_SKU_Lookup__c;
                tempLi.skuLabel = li.ASI_HK_CRM_SKU_Lookup__c != null ? li.ASI_HK_CRM_SKU_Lookup__r.Name : null;
                tempLi.skuBenchmark = li.ASI_HK_CRM_SKU_Lookup__c != null && li.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c != null ? sbIdToBMMap.get(li.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c) : null;
                tempLi.pricingItem = li.ASI_CRM_HK_Pricing_Item__c;
                tempLi.mechanicId = li.ASI_HK_CRM_Mechanic__c;
                tempLi.mechanicLabel = li.ASI_HK_CRM_Mechanic__r.Name;
                String mBaseType = li.ASI_HK_CRM_Mechanic__c != null ? MECHANIC_TO_BASE_TYPE.get(li.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c) : null;
                tempLi.mechanicBaseType = mBaseType != null ? mBaseType : 'other';
                tempLi.mechanicCode = li.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c;
                tempLi.qty = li.ASI_HK_CRM_Target_Volume_Qty__c;
                tempLi.price = li.ASI_HK_CRM_Price__c;
                tempLi.isPouring = li.ASI_HK_CRM_Pouring__c;
                tempLi.investmentValue = li.ASI_HK_CRM_Investment_Value__c;
                tempLi.paymentCondition = li.ASI_HK_CRM_Conditions_for_Payment__c;
                
                if (ChannelReferencePriceMap.containsKey(li.ASI_HK_CRM_SKU_Lookup__c) 
                    && (tempLi.referencePrice == null || tempLi.referencePrice == 0))
                    tempLi.referencePrice = ChannelReferencePriceMap.get(li.ASI_HK_CRM_SKU_Lookup__c);
                        
                if (tempLi.price == Null || tempLi.price == 0)
                    tempLi.price = tempLi.referencePrice ;
                
                tempLi.buyAndFreeList = new List<List<Decimal>>();
                for (Integer i = 1; i <= ASI_HK_CRM_PreApprovalFormItemGenerator.MAX_NUM_OF_FOC_PAIR; i++) {
                    Decimal buy = (Decimal)li.get(ASI_HK_CRM_PreApprovalFormItemGenerator.buyField(i));
                    Decimal free = (Decimal)li.get(ASI_HK_CRM_PreApprovalFormItemGenerator.freeField(i));
                    if (buy != null && free != null) {
                        tempLi.buyAndFreeList.add(new Decimal[] {buy, free});
                    }
                }
                tempLi.rebateDiscPercent = li.ASI_HK_CRM_Rebate_Disc_Percent__c;
                tempLi.rebateDiscAmt = li.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                tempLi.fixAmt = li.ASI_HK_CRM_Fixed_Amount__c;
                //tempLi.allPrdt = li.ASI_HK_CRM_SKU_Lookup__r.ASI_CRM_HK_All_Product__c; //20160317, added by Leo
                //20160318, added by Leo
                if(li.ASI_HK_CRM_SKU_Lookup__r.Name != null && allPrdtName != null
                   && li.ASI_HK_CRM_SKU_Lookup__r.Name == allPrdtName)
                    tempLi.allPrdt = True;
                else
                    tempLi.allPrdt = False;
                //20160318, added by Leo
                result.add(tempLi);
            }
        }
        return result;
    }
    
    @RemoteAction
    public static List<ASI_HK_CRM_NormalProduct> normalProductList(String custId) {
        List<ASI_HK_CRM_NormalProduct> result = new List<ASI_HK_CRM_NormalProduct>();
        if (!String.isBlank(custId)) {
            Account acct = [SELECT Id, ASI_HK_CRM_Customer_Number__c, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Channel__c,ASI_HK_CRM_Customer_Type__c 
                            //, ASI_CRM_AccountAdditionalField__pr.ASI_CRM_Pricing_Channel__c
                            FROM Account WHERE Id = :custId];
            //ASI_CRM_AccountsAdditionalField__c accAdd = [SELECT id, ASI_CRM_Pricing_Channel__c FROM ASI_CRM_AccountsAdditionalField__c 
            //                                                   WHERE ASI_CRM_Account__c = :custId And RecordType.developername = 'ASI_CRM_HK_Outlet' Limit 1];
           // Account acct = [SELECT Id, ASI_HK_CRM_Customer_Number__c, ASI_HK_CRM_Local_Channel__c, ASI_HK_CRM_Channel__c FROM Account WHERE Id = :custId];
            //string custType = acct.ASI_HK_CRM_Customer_Type__c;
            //string subStringChannel = acct.ASI_HK_CRM_Customer_Type__c.substring(0,3);
            //for (ASI_HK_CRM_Channel_Local_Channel_Map__c PricingChannel: [SELECT ASI_HK_CRM_Channel__c, ASI_HK_CRM_Pricing_Channel__c From ASI_HK_CRM_Channel_Local_Channel_Map__c]) {
            //  PricingChannelMap.put(PricingChannel.ASI_HK_CRM_Channel__c, PricingChannel.ASI_HK_CRM_Pricing_Channel__c);
            //}
            string accChannel = acct.ASI_HK_CRM_Channel__c.substring(0,3) + '%';
            //system.debug('accChannel::::::::::::::::::'+ accChannel);
            ASI_HK_CRM_Channel_Local_Channel_Map__c PricingChannelMap = [SELECT ASI_HK_CRM_Channel__c, ASI_HK_CRM_Pricing_Channel__c 
                                                                      From ASI_HK_CRM_Channel_Local_Channel_Map__c
                                                                      Where ASI_HK_CRM_Channel__c Like: accChannel
                                                                      Limit 1];
            string pricingChennel;
            string subStringChannel;
            if (PricingChannelMap.ASI_HK_CRM_Pricing_Channel__c != null){
                pricingChennel = PricingChannelMap.ASI_HK_CRM_Pricing_Channel__c;
                subStringChannel = pricingChennel.substring(0,3);
            }else{
                subStringChannel = '';
            }
                
            List<ASI_HK_CRM_Customer_Product_Price__c> ChannelBasePrice = [select ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_Bottle_Price__c FROM ASI_HK_CRM_Customer_Product_Price__c 
                                                                           WHERE (//ASI_CRM_HK_Channel__c = :acct.ASI_HK_CRM_Channel__c 
                                                                                  //Or 
                                                                               ASI_CRM_HK_Channel__c =: pricingChennel 
                                                                                //OR ASI_CRM_HK_Channel__c =: subStringChannel
                                                                             )
                                                                           AND recordtype.developername = 'ASI_CRM_HK_Channel_PAF_Price'];
            
            system.debug('SKU ChannelBasePrice List Size Before=======' + ChannelReferencePriceMap);            for (ASI_HK_CRM_Customer_Product_Price__c channelprice : ChannelBasePrice) {
                ChannelReferencePriceMap.put(channelprice.ASI_HK_CRM_SKU_Lookup__c, channelprice.ASI_HK_CRM_Bottle_Price__c);
            }
            system.debug('SKU ChannelBasePrice List Size After=======' + ChannelReferencePriceMap);
            system.debug(ChannelReferencePriceMap);
            List<ASI_HK_CRM_Customer_Product_Price__c> CustomerBasePrice = [select ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_Bottle_Price__c FROM ASI_HK_CRM_Customer_Product_Price__c WHERE ASI_HK_CRM_Customer_Name__c =:custId AND recordtype.developername = 'ASI_CRM_HK_Customer_PAF_Price'];
            for (ASI_HK_CRM_Customer_Product_Price__c cusprice : CustomerBasePrice) {
                CustomerReferencePriceMap.put(cusprice.ASI_HK_CRM_SKU_Lookup__c, cusprice.ASI_HK_CRM_Bottle_Price__c);
            }
            system.debug('RTDEVNAME_SKU:   ' +RTDEVNAME_SKU); 
            List<ASI_MFM_SKU_Code__c> skuList = [
                SELECT Id, Name, ASI_MFM_SKU_Code__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c
                    ,ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c , ASI_HK_CRM_Base_Price__c
                    ,ASI_MFM_Item_Group__r.Name, ASI_MFM_Item_Group__c , ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Description__c
                    ,ASI_HK_CRM_Product_Category__r.Name, ASI_HK_CRM_Product_Brand__r.Name
                    ,ASI_HK_CRM_Std_Bottle_Size__c, ASI_HK_CRM_Active__c
                    //,ASI_CRM_HK_All_Product__c //20160317, added by Leo
                FROM ASI_MFM_SKU_Code__c
                WHERE RecordType.DeveloperName = :RTDEVNAME_SKU //AND ASI_HK_CRM_Active__c = TRUE
                    AND ASI_HK_CRM_IsPOSProduct__c != TRUE 
                    ORDER BY ASI_MFM_Sub_brand__r.Name
                            //ASI_MFM_Item_Group__r.Name,
                            //ASI_HK_CRM_Std_Bottle_Size__c //20160408, edited by Leo
                            //Name, 
                            //ASI_HK_CRM_Product_Category__r.Name, 
                            //ASI_HK_CRM_Product_Brand__r.Name, 
                            //ASI_MFM_Sub_brand__r.Name
                            
            ];
            //2016-02-01, added by Leo
            Map<Id, ASI_MFM_SKU_Code__c> igSKUmap = new Map<Id, ASI_MFM_SKU_Code__c>();
            for(ASI_MFM_SKU_Code__c sku : skuList)
            {
                if(sku.ASI_HK_CRM_Active__c == false){
                    continue;
                }
                if(!igSKUmap.containsKey(sku.ASI_MFM_Item_Group__c))
                    igSKUmap.put(sku.ASI_MFM_Item_Group__c, sku);
                if(ChannelReferencePriceMap.containsKey(sku.id))
                    igSKUmap.put(sku.ASI_MFM_Item_Group__c, sku);
            }//end for
            //2016-02-01, added by Leo
            Date todayDate = Date.today();
            List<ASI_HK_CRM_Customer_Product_Price__c> custPdPriceList = [
                SELECT Id, Name, ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_Bottle_Price__c, ASI_HK_CRM_Case_Price__c
                FROM ASI_HK_CRM_Customer_Product_Price__c
                WHERE RecordType.DeveloperName = :RTDEVNAME_CUST_PD_PRICE AND ASI_HK_CRM_Customer_Name__c = :custId
                    AND (ASI_HK_CRM_Effective_Date__c = NULL OR ASI_HK_CRM_Expiry_Date__c = NULL
                        OR (ASI_HK_CRM_Effective_Date__c <= :todayDate AND ASI_HK_CRM_Expiry_Date__c >= :todayDate))
            ];
            Map<ID, ASI_HK_CRM_Customer_Product_Price__c> pdIdToCustPdPriceMap = new Map<ID, ASI_HK_CRM_Customer_Product_Price__c>();
            for (ASI_HK_CRM_Customer_Product_Price__c custPdPrice : custPdPriceList) {
                pdIdToCustPdPriceMap.put(custPdPrice.ASI_HK_CRM_SKU_Lookup__c, custPdPrice);
            }
            String localChannel = acct.ASI_HK_CRM_Local_Channel__c;
            if (String.isBlank(localChannel)) {
                localChannel = localChannelByChannel(acct.ASI_HK_CRM_Channel__c);
            }
            Map<ID, Decimal> sbIdToBMMap = sbIdToInvestmentBenchmarkMap(localChannel);
            String OldItemGp = '';
            String NewItemGp = '';
            Map<Id,ASI_MFM_SKU_Code__c> skuMap = new Map<Id,ASI_MFM_SKU_Code__c>(skuList);
            for (ASI_MFM_SKU_Code__c sku : igSKUmap.values()) { //20160201, changed by Leo, loop sku list -> sku map
                NewItemGp = sku.ASI_MFM_Item_Group__r.Name;
                if (NewItemGp != OldItemGp){
                    skuMap.remove(sku.Id);
                    ASI_HK_CRM_NormalProduct pd = new ASI_HK_CRM_NormalProduct();
                    pd.id = sku.Id;
                    pd.code = sku.ASI_MFM_SKU_Code__c;
                    pd.name = sku.Name;
                    pd.subBrandName = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.Name : '';
                    pd.subBrandId = sku.ASI_MFM_Sub_brand__c;
                    pd.subBrandCode = sku.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c;
                    pd.brandType = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c : null;
                    ASI_HK_CRM_Customer_Product_Price__c custPdPrice = pdIdToCustPdPriceMap.get(sku.Id);
                    pd.basePrice = custPdPrice != null ? custPdPrice.ASI_HK_CRM_Bottle_Price__c : sku.ASI_HK_CRM_Base_Price__c;
                    pd.stdBottleSize = sku.ASI_HK_CRM_Std_Bottle_Size__c;
                    pd.benchmark = sku.ASI_MFM_Sub_brand__c != null ? sbIdToBMMap.get(sku.ASI_MFM_Sub_brand__c) : null;
                    pd.itemGroupName = sku.ASI_MFM_Item_Group__r.Name;
                    pd.itemGroupId = sku.ASI_MFM_Item_Group__c;
                    pd.pricingItem = sku.ASI_MFM_Item_Group__r.Name;
                    pd.showInProductList = true;
                    pd.active = sku.ASI_HK_CRM_Active__c;
                    //pd.allPrdt = sku.ASI_CRM_HK_All_Product__c; //20160317, added by Leo
                    //20160318, added by Leo
                    if(pd.Name != null && allPrdtName != null
                       && pd.Name == allPrdtName)
                        pd.allPrdt = True;
                    else
                        pd.allPrdt = False;
                    //20160318, added by Leo
                    // pd.pricingItem = sku.ASI_MFM_Item_Group__c != null ? sku.ASI_MFM_Item_Group__r.Name : sku.Name;
                    //if (acct.ASI_HK_CRM_Customer_Number__c.startsWith('13')) {
                    //  if (CustomerReferencePriceMap.containsKey(sku.Id))
                    //        pd.referencePrice = CustomerReferencePriceMap.get(sku.Id);
                        System.debug('normalProductList | sku.Id: ' + sku.Id);
                        System.debug('normalProductList | ChannelReferencePriceMap.containsKey(sku.Id): ' + ChannelReferencePriceMap.containsKey(sku.Id));
                        if (ChannelReferencePriceMap.containsKey(sku.Id) 
                            && (pd.referencePrice == null || pd.referencePrice == 0)){
                            pd.referencePrice = ChannelReferencePriceMap.get(sku.Id);
                                system.debug('pd.referencePrice'+pd.referencePrice);
                        }
                    //} else {
                        
                    //}
                    result.add(pd);
                }
                OldItemGp = NewItemGp;
                NewItemGp = '';
            }
            for(Id skuId : skuMap.keySet()){
                ASI_MFM_SKU_Code__c sku = skuMap.get(skuId);
                ASI_HK_CRM_NormalProduct pd = new ASI_HK_CRM_NormalProduct();
                    pd.id = sku.Id;
                    pd.code = sku.ASI_MFM_SKU_Code__c;
                    pd.name = sku.Name;
                    pd.subBrandName = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.Name : '';
                    pd.subBrandId = sku.ASI_MFM_Sub_brand__c;
                    pd.subBrandCode = sku.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c;
                    pd.brandType = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c : null;
                    ASI_HK_CRM_Customer_Product_Price__c custPdPrice = pdIdToCustPdPriceMap.get(sku.Id);
                    pd.basePrice = custPdPrice != null ? custPdPrice.ASI_HK_CRM_Bottle_Price__c : sku.ASI_HK_CRM_Base_Price__c;
                    pd.stdBottleSize = sku.ASI_HK_CRM_Std_Bottle_Size__c;
                    pd.benchmark = sku.ASI_MFM_Sub_brand__c != null ? sbIdToBMMap.get(sku.ASI_MFM_Sub_brand__c) : null;
                    pd.itemGroupName = sku.ASI_MFM_Item_Group__r.Name;
                    pd.itemGroupId = sku.ASI_MFM_Item_Group__c;
                    pd.pricingItem = sku.ASI_MFM_Item_Group__r.Name;
                    pd.showInProductList = false;
                    pd.active = sku.ASI_HK_CRM_Active__c;
                
                    if(pd.Name != null && allPrdtName != null
                       && pd.Name == allPrdtName)
                        pd.allPrdt = True;
                    else
                        pd.allPrdt = False;
                        if (ChannelReferencePriceMap.containsKey(sku.Id) 
                            && (pd.referencePrice == null || pd.referencePrice == 0)){
                            pd.referencePrice = ChannelReferencePriceMap.get(sku.Id);
                                system.debug('pd.referencePrice'+pd.referencePrice);
                        }
                    //} else {
                        
                    //}
                    result.add(pd);
            }
            
        }
        
        return result;
    }
    
    @RemoteAction
    public static ASI_HK_CRM_SaveResult saveChanges(String headerId, List<ASI_HK_CRM_PAFLineItem> remoteLineItems) {
        ASI_HK_CRM_SaveResult result = new ASI_HK_CRM_SaveResult();
        result.success = false;
        
        try {
            if (isNonEmptyId(headerId)) {
                String tempPaymentConditon = '';   //Store the payment condition in each lineItem
                ASI_HK_CRM_Pre_Approval_Form__c tempPAF = [select id, ASI_HK_CRM_Conditions_of_Payment__c, ASI_CRM_HK_Calculate_on_Net_Price__c from ASI_HK_CRM_Pre_Approval_Form__c
                                                           where id =: headerId];

                Map<String, String> newCommentSet = new Map<String, String>();  //Store the comment of each mechanic;
                
                Map<ID, ASI_HK_CRM_Pre_Approval_Form_Item__c> existingLineItemMap = new Map<ID, ASI_HK_CRM_Pre_Approval_Form_Item__c>(
                (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)[
                    SELECT Id, LastModifiedDate, ASI_HK_CRM_Mechanic__r.name   //Add by Abel Mechanic Name
                    FROM ASI_HK_CRM_Pre_Approval_Form_Item__c
                    WHERE ASI_HK_CRM_Pre_Approval_Form_Lookup__c = :headerId
                    FOR UPDATE
                ]);

                List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mechanics =
                [
                    SELECT Id, Name,ASI_HK_CRM_Mechanic_Category__c, ASI_HK_CRM_Mechanic_Type__c, ASI_HK_CRM_Code__c, ASI_CRM_HK_Active__c, ASI_CRM_Short_Name__c 
                    FROM ASI_HK_CRM_Pre_Approval_Form_Mechanic__c  WHERE ASI_CRM_HK_Active__c = true
                    order by ASI_HK_CRM_Code__c, Name
                ]; 
                
                Set<ID> newIdSet = new Set<ID>();
                //List<ASI_HK_CRM_Pre_Approval_Form_Item__c> insertLineItems = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
                //List<ASI_HK_CRM_Pre_Approval_Form_Item__c> updateLineItems = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
                List<ASI_HK_CRM_Pre_Approval_Form_Item__c> deleteLineItems = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
                Map<String,ASI_HK_CRM_Pre_Approval_Form_Item__c> insertLineItems = new Map<String,ASI_HK_CRM_Pre_Approval_Form_Item__c>();
                Map<String,ASI_HK_CRM_Pre_Approval_Form_Item__c> updateLineItems = new Map<String,ASI_HK_CRM_Pre_Approval_Form_Item__c>();
                if (remoteLineItems != null) {
                    for (ASI_HK_CRM_PAFLineItem remoteLineItem : remoteLineItems) {
                        ASI_HK_CRM_Pre_Approval_Form_Item__c lineItem;
                        
                        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') {
                            System.debug('payk1');
                            lineItem = existingLineItemMap.get(remoteLineItem.id);
                            
                            if (lineItem != null) {
                                System.debug('payk2');
                                updateLineItemFromRemote(lineItem, remoteLineItem);
                                if(!lineItem.ASI_CRM_HK_All_Product__c) //20160413, added by Leo
                                    lineItemSet.add(remoteLineItem.skuId); //20160413, added by Leo
                                updateLineItems.put(''+lineItem.ASI_HK_CRM_SKU_Lookup__c+lineItem.ASI_HK_CRM_Mechanic__c,lineItem);
                                newIdSet.add(remoteLineItem.id);
                            } else {
                                System.debug('payk4');
                                result.messages.add(String.format('Line item with ID {0} is not found', new String[] {remoteLineItem.id}));
                                break;
                            }
                        } else {
                            System.debug('payk5');
                            
                            lineItem = new ASI_HK_CRM_Pre_Approval_Form_Item__c();
                            updateLineItemFromRemote(lineItem, remoteLineItem);
                            System.debug('payk5.2');
                            if(!lineItem.ASI_CRM_HK_All_Product__c) //20160413, added by Leo
                                lineItemSet.add(remoteLineItem.skuId); //20160413, added by Leo
                            //********************************************************************
                            lineItem.ASI_HK_CRM_Pre_Approval_Form_Lookup__c = headerId;
                            insertLineItems.put(''+lineItem.ASI_HK_CRM_SKU_Lookup__c+lineItem.ASI_HK_CRM_Mechanic__c,lineItem);
                        }

                        if (lineItem.ASI_HK_CRM_Mechanic__c != null)
                        {
                            ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech = mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c);

                            if (lineItem.ASI_HK_CRM_Conditions_for_Payment__c != null && lineItem.ASI_HK_CRM_Conditions_for_Payment__c != '' && newCommentSet.get(mech.ASI_HK_CRM_Code__c) == null)
                            {
                                newCommentSet.put(mech.ASI_HK_CRM_Code__c, mech.ASI_CRM_Short_Name__c + ' - ' + lineItem.ASI_HK_CRM_Conditions_for_Payment__c);
                            }
                        }
                    }

                    for (ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech : mechanics)
                    {
                        String str = newCommentSet.get(mech.ASI_HK_CRM_Code__c);

                        if (str != null && str != '')
                        {
                            tempPaymentConditon += (str + '\n\n');
                        }
                    }

                    System.debug('tempPaymentConditon: ' + tempPaymentConditon);
                    tempPAF.ASI_HK_CRM_Conditions_of_Payment__c = tempPaymentConditon;   //Add comments to salesOrder
                    tempPAF.ASI_CRM_HK_Calculate_on_Net_Price__c=true;  
                    ///20160413, added by Leo
                    if(allPrdtSet.size() > 0)
                    {
                        for(String key: allPrdtSet)
                        {
                            if(updateLineItems.containsKey(key))
                            {
                                ASI_HK_CRM_Pre_Approval_Form_Item__c lineItem = updateLineItems.get(key);
                                System.Debug('check id: '+lineItem.id+',ASI_HK_CRM_Mechanic__c: '+lineItem.ASI_HK_CRM_Mechanic__c);
                                
                                if(lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c != null)
                                {                                   
                                    if(mechanicMap.containsKey(lineItem.ASI_HK_CRM_Mechanic__c) && 
                                        (mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A01' ||mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A06' ||  mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A08')){
                                            System.Debug('ASI_HK_CRM_Code__c: '+mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c+', totalSalesVal: '+totalSalesVal+', totalDistcountBT: '+totalDistcountBT+',ASI_HK_CRM_Rebate_Disc_Percent__c: '+lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c);
                                            lineItem.ASI_HK_CRM_Investment_Value__c = (totalSalesVal-totalDistcountBT) * lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c /100;
                                    }else
                                        lineItem.ASI_HK_CRM_Investment_Value__c = totalSalesVal * lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c /100;
                                }
                                else if(lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null)
                                {
                                    lineItem.ASI_HK_CRM_Investment_Value__c = totalQty * lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                                }
                                updateLineItems.put(''+lineItem.ASI_HK_CRM_SKU_Lookup__c+lineItem.ASI_HK_CRM_Mechanic__c,lineItem);
                                System.Debug('LCheck:- Update-'+updateLineItems);
                            }
                            else if(insertLineItems.containsKey(key))
                            {
                                ASI_HK_CRM_Pre_Approval_Form_Item__c lineItem = insertLineItems.get(key);
                                if(mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A06'){
                                    System.Debug('A06 %: '+lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c);
                                }
                                if(lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c != null)
                                {
                                    if(mechanicMap.containsKey(lineItem.ASI_HK_CRM_Mechanic__c) && 
                                        (mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A01' ||mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A06' ||  mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A08')){
                                            System.Debug('ASI_HK_CRM_Code__c: '+mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c+', totalSalesVal: '+totalSalesVal+', totalDistcountBT: '+totalDistcountBT+',ASI_HK_CRM_Rebate_Disc_Percent__c: '+lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c);                                       
                                            lineItem.ASI_HK_CRM_Investment_Value__c = (totalSalesVal-totalDistcountBT) * lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c /100;
                                    }else
                                        lineItem.ASI_HK_CRM_Investment_Value__c = totalSalesVal * lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c /100;
                                }
                                else if(lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null)
                                {
                                    lineItem.ASI_HK_CRM_Investment_Value__c = totalQty * lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                                }
                                insertLineItems.put(''+lineItem.ASI_HK_CRM_SKU_Lookup__c+lineItem.ASI_HK_CRM_Mechanic__c,lineItem);
                                System.Debug('LCheck:- Insert-'+insertLineItems);
                            }
                        }
                    }
                    
                    for(ASI_HK_CRM_Pre_Approval_Form_Item__c existingLineItem : updateLineItems.values()){
                                
                        if(existingLineItem.ASI_HK_CRM_Rebate_Disc_Percent__c != null && mechanicMap.containsKey(existingLineItem.ASI_HK_CRM_Mechanic__c) && 
                                (mechanicMap.get(existingLineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A06')){
                            existingLineItem.ASI_CRM_NetPrice_Discount__c= skuDiscountMapOnInvoice_bt.containsKey(existingLineItem.ASI_HK_CRM_SKU_Lookup__c)? skuDiscountMapOnInvoice_bt.get(existingLineItem.ASI_HK_CRM_SKU_Lookup__c):0;
                            
                            updateLineItems.put(''+existingLineItem.ASI_HK_CRM_SKU_Lookup__c+existingLineItem.ASI_HK_CRM_Mechanic__c,existingLineItem);
                            System.Debug(updateLineItems.get(''+existingLineItem.ASI_HK_CRM_SKU_Lookup__c+existingLineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Investment_Value__c);
                        }
                        
                        if(mechanicMap.containsKey(existingLineItem.ASI_HK_CRM_Mechanic__c) && (mechanicMap.get(existingLineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A02')){
                            existingLineItem.ASI_CRM_NetPrice_Discount__c= skuDiscountMapOnInvoice_bt.containsKey(existingLineItem.ASI_HK_CRM_SKU_Lookup__c)? skuDiscountMapOnInvoice_bt.get(existingLineItem.ASI_HK_CRM_SKU_Lookup__c):0; 
                            existingLineItem.ASI_CRM_Extra_Discount__c= skuDiscountMapRebate_bt.containsKey(existingLineItem.ASI_HK_CRM_SKU_Lookup__c)? skuDiscountMapRebate_bt.get(existingLineItem.ASI_HK_CRM_SKU_Lookup__c):0;
                            
                            updateLineItems.put(''+existingLineItem.ASI_HK_CRM_SKU_Lookup__c+existingLineItem.ASI_HK_CRM_Mechanic__c,existingLineItem);
                            System.Debug(updateLineItems.get(''+existingLineItem.ASI_HK_CRM_SKU_Lookup__c+existingLineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Investment_Value__c);
                        }
                    }
                    
                    for(ASI_HK_CRM_Pre_Approval_Form_Item__c existingLineItem : insertLineItems.values()){
                                
                        if(existingLineItem.ASI_HK_CRM_Rebate_Disc_Percent__c != null && mechanicMap.containsKey(existingLineItem.ASI_HK_CRM_Mechanic__c) && 
                                (mechanicMap.get(existingLineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A06')){
                            existingLineItem.ASI_CRM_NetPrice_Discount__c= skuDiscountMapOnInvoice_bt.containsKey(existingLineItem.ASI_HK_CRM_SKU_Lookup__c)? skuDiscountMapOnInvoice_bt.get(existingLineItem.ASI_HK_CRM_SKU_Lookup__c):0;
                            insertLineItems.put(''+existingLineItem.ASI_HK_CRM_SKU_Lookup__c+existingLineItem.ASI_HK_CRM_Mechanic__c,existingLineItem);
                        }
                        
                        if(mechanicMap.containsKey(existingLineItem.ASI_HK_CRM_Mechanic__c) && (mechanicMap.get(existingLineItem.ASI_HK_CRM_Mechanic__c).ASI_HK_CRM_Code__c=='A02')){
                            existingLineItem.ASI_CRM_NetPrice_Discount__c= skuDiscountMapOnInvoice_bt.containsKey(existingLineItem.ASI_HK_CRM_SKU_Lookup__c)? skuDiscountMapOnInvoice_bt.get(existingLineItem.ASI_HK_CRM_SKU_Lookup__c):0;
                            existingLineItem.ASI_CRM_Extra_Discount__c= skuDiscountMapRebate_bt.containsKey(existingLineItem.ASI_HK_CRM_SKU_Lookup__c)? skuDiscountMapRebate_bt.get(existingLineItem.ASI_HK_CRM_SKU_Lookup__c):0;
                            
                            insertLineItems.put(''+existingLineItem.ASI_HK_CRM_SKU_Lookup__c+existingLineItem.ASI_HK_CRM_Mechanic__c,existingLineItem);
                        }
                    }
                    
                    //20160413, added by Leo
                //}change by mark to prevent all items be deleted issue
                
                    if (existingLineItemMap.size() != newIdSet.size()) {
                        for (ASI_HK_CRM_Pre_Approval_Form_Item__c existingLineItem : existingLineItemMap.values()) {
                            if (!newIdSet.contains(existingLineItem.Id))
                                deleteLineItems.add(existingLineItem);
                        }
            
            if(deleteLineItems.size()> existingLineItemMap.size()/2)
                            deleteLineItems.clear();
                    }
                    
                    System.Savepoint sp = database.setSavepoint();
                    try {
System.Debug('deleteLineItems size: '+deleteLineItems.size());
System.Debug('insertLineItems size: '+insertLineItems.size());  
System.Debug('updateLineItems size: '+updateLineItems.size());  

                        update tempPAF;
                        delete deleteLineItems;
                        insert insertLineItems.values();
                        update updateLineItems.values();
                        result.success = true;
                    } catch (DmlException dmle) {
                        database.rollback(sp);
                        Set<String> errMsgs = new Set<String>();
                        Integer size = dmle.getNumDml();
                        for (Integer i = 0; i < size; i++) {
                            errMsgs.add(dmle.getDmlMessage(i));
                        }
                        result.messages.addAll(errMsgs);
                    } catch (Exception e) {
                        database.rollback(sp);
                        result.messages.add(e.getMessage());
                    }
                }//remoteLineItems != null
            } else {
                result.messages.add('Invalid header ID');
            }
        } catch (Exception e) {
            result.messages.add(e.getMessage());
        }
        
        return result;
    }
    private static void updateLineItemFromRemote(ASI_HK_CRM_Pre_Approval_Form_Item__c lineItem, ASI_HK_CRM_PAFLineItem remoteLineItem) {
        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') lineItem.Id = remoteLineItem.id;
        lineItem.ASI_HK_CRM_SKU_Lookup__c = remoteLineItem.skuId;
        lineItem.ASI_HK_CRM_Mechanic__c = remoteLineItem.mechanicId;
        lineItem.ASI_HK_CRM_Target_Volume_Qty__c = remoteLineItem.qty;
        lineItem.ASI_HK_CRM_Price__c = remoteLineItem.price;
        lineItem.ASI_HK_CRM_Pouring__c = remoteLineItem.isPouring;
        lineItem.ASI_HK_CRM_Investment_Value__c = null;
        lineItem.ASI_HK_CRM_Conditions_for_Payment__c = remoteLineItem.paymentCondition;
        lineItem.ASI_CRM_HK_All_Product__c = remoteLineItem.allPrdt; //20160318, added by Leo
        //20160413, added by Leo
        if(!lineItemSet.contains(remoteLineItem.skuId) && !lineItem.ASI_CRM_HK_All_Product__c)
        {
            totalQty += lineItem.ASI_HK_CRM_Target_Volume_Qty__c;
            totalSalesVal += (lineItem.ASI_HK_CRM_Target_Volume_Qty__c*lineItem.ASI_HK_CRM_Price__c);
        }
        if(lineItem.ASI_CRM_HK_All_Product__c 
           && lineItem.ASI_HK_CRM_SKU_Lookup__c!=null 
           && lineItem.ASI_HK_CRM_Mechanic__c!=null)
        {
            allPrdtSet.add(''+lineItem.ASI_HK_CRM_SKU_Lookup__c+lineItem.ASI_HK_CRM_Mechanic__c);
        }
        //20160413, added by Leo*/
        //lineItem.ASI_CRM_HK_All_Product__c = True;
        //lineItem.ASI_HK_CRM_Mechanic__r.Name = mechanicMap.get(lineItem.ASI_HK_CRM_Mechanic__c);
        //Add by Abel
        
        Integer pairCount = 1;
        if (remoteLineItem.buyAndFreeList != null) {
            for (List<Decimal> buyAndFree : remoteLineItem.buyAndFreeList) {
                if (buyAndFree.size() == 2) {
                    lineItem.put(ASI_HK_CRM_PreApprovalFormItemGenerator.buyField(pairCount), buyAndFree[0]);
                    lineItem.put(ASI_HK_CRM_PreApprovalFormItemGenerator.freeField(pairCount), buyAndFree[1]);
                }
                if (pairCount == ASI_HK_CRM_PreApprovalFormItemGenerator.MAX_NUM_OF_FOC_PAIR) break;
                pairCount++;
            }
        }
        
        lineItem.ASI_HK_CRM_Rebate_Disc_Percent__c = remoteLineItem.rebateDiscPercent;
        lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c = remoteLineItem.rebateDiscAmt;
        lineItem.ASI_HK_CRM_Fixed_Amount__c = remoteLineItem.fixAmt;
        
        if( mechanicMap.containsKey(remoteLineItem.mechanicId) && mechanicMap.get(remoteLineItem.mechanicId).ASI_HK_CRM_Code__c=='A04') {//!lineItem.ASI_CRM_HK_All_Product__c &&
            totalDistcountBT+= (lineItem.ASI_HK_CRM_Target_Volume_Qty__c* (lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c==null? 0 :lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c));
        
            if( lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c!=null)
                skuDiscountMapOnInvoice_bt.put(lineItem.ASI_HK_CRM_SKU_Lookup__c,lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c);
        }
        
        if( mechanicMap.containsKey(remoteLineItem.mechanicId) && mechanicMap.get(remoteLineItem.mechanicId).ASI_HK_CRM_Code__c=='A07') 
            skuDiscountMapRebate_bt.put(lineItem.ASI_HK_CRM_SKU_Lookup__c,lineItem.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c);
            
        
        if(lineItem.ASI_CRM_HK_All_Product__c)
            totalDiscountRate+=remoteLineItem.rebateDiscPercent;
    }
    
    public List<List<String>> getSubBrandSearchOptions() {
        List<List<String>> result = new List<List<String>>();
        //Updated by Wilken 20160201, exclude Sub-brand without description 
        List<ASI_MFM_Sub_brand__c> sbList = [
            SELECT Id, Name, ASI_MFM_Sub_brand_Description__c
            FROM ASI_MFM_Sub_brand__c
            WHERE RecordType.DeveloperName = :RTDEVNAME_SB AND ASI_MFM_Sub_brand_Description__c != null
            AND ASI_MFM_Inactive__c = FALSE
            ORDER BY ASI_MFM_Sub_brand_Description__c
        ];
        for (ASI_MFM_Sub_brand__c sb : sbList) {
            List<String> mOption = new String[2];
            mOption[0] = String.escapeSingleQuotes(sb.Id);
            mOption[1] = sb.ASI_MFM_Sub_brand_Description__c == null ? '' : sb.ASI_MFM_Sub_brand_Description__c;
            result.add(mOption);
        }
        return result;
    }

    //Abel Changed from Map to List
    public static List<List<String>> getMechanicOptions() {
        List<List<String>> result = new List<List<String>>();
        List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mechanics = [
            SELECT Id, Name,ASI_HK_CRM_Mechanic_Category__c, ASI_HK_CRM_Mechanic_Type__c, ASI_HK_CRM_Code__c, ASI_CRM_HK_Active__c, ASI_CRM_Short_Name__c 
            FROM ASI_HK_CRM_Pre_Approval_Form_Mechanic__c  WHERE ASI_CRM_HK_Active__c = true
            order by ASI_HK_CRM_Code__c, Name]; 
        for (ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mechanic : mechanics) {
            List<String> mOption = new String[6];
            mOption[0] = String.escapeSingleQuotes(mechanic.Id);
            //mOption[1] = mechanic.Name;
            mOption[1] = String.valueOf(mechanic.ASI_HK_CRM_Mechanic_Category__c) + ' - ' + String.valueOf(mechanic.ASI_CRM_Short_Name__c);   //Add by Abel to display category value
            String baseType = MECHANIC_TO_BASE_TYPE.get(mechanic.ASI_HK_CRM_Mechanic_Type__c);
            mOption[2] = baseType != null ? baseType : 'other';
            mOption[3] = String.valueOf(mechanic.ASI_HK_CRM_Code__c);
            mOption[4] = mechanic.ASI_CRM_HK_Active__c ? 'Y' : 'N';
            mOption[5] = mechanic.ASI_CRM_Short_Name__c;
            
            result.add(mOption);
        }
        return result;
    }
    
    
    private static String localChannelByChannel(String channel) {
        String result = null;
        if (String.isBlank(channel)) {
            List<ASI_HK_CRM_Channel_Local_Channel_Map__c> channelMapObjList = [SELECT Id, ASI_HK_CRM_Local_Channel__c FROM ASI_HK_CRM_Channel_Local_Channel_Map__c WHERE ASI_HK_CRM_Channel__c = :channel];
            if (channelMapObjList.size() > 0)
                result = channelMapObjList[0].ASI_HK_CRM_Local_Channel__c;
        }
        return result;
    }
    private static Map<ID, Decimal> sbIdToInvestmentBenchmarkMap(String localChannel) {
        Map<ID, Decimal> sbIdToBMMap = new Map<ID, Decimal>();
        List<ASI_HK_CRM_SubBrand_Investment_Benchmark__c> sbInvestBMs = [
            SELECT Id, ASI_HK_CRM_Sub_Brand__c, ASI_HK_CRM_Benchmark_Percent__c, ASI_HK_CRM_Local_Channel__c
            FROM ASI_HK_CRM_SubBrand_Investment_Benchmark__c
            WHERE ASI_HK_CRM_Local_Channel__c = :localChannel
        ];
        for (ASI_HK_CRM_SubBrand_Investment_Benchmark__c sbInvestBM : sbInvestBMs) {
            if (sbInvestBM.ASI_HK_CRM_Sub_Brand__c == null) {
                throw new ASI_HK_CRM_CustomException(String.format(
                    'No Sub-Brand in PAF Sub-Brand Investment Benchmark record. (ID: {0}; Local Channel: {1})'
                    , new String[] {sbInvestBM.Id, sbInvestBM.ASI_HK_CRM_Local_Channel__c}
                ));
            }
            sbIdToBMMap.put(sbInvestBM.ASI_HK_CRM_Sub_Brand__c, sbInvestBM.ASI_HK_CRM_Benchmark_Percent__c);
        }
        return sbIdToBMMap;
    }
    
    public PageReference refreshPage(){
        PageReference refPage = ApexPages.currentPage();
        refPage.setRedirect(true);
        return refPage;
    }
    
    private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
    private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }

    public class ASI_HK_CRM_PAFLineItem {
        public String id { get; set; }
        public String skuId { get; set; }
        public String skuLabel { get; set; }
        public String pricingItem { get; set; }
        public Decimal skuBenchmark { get; set; }
        public String mechanicId { get; set; }
        public String mechanicLabel { get; set; }
        public String mechanicBaseType { get; set; }
        public String mechanicCode { get; set; }
        public List<List<Decimal>> buyAndFreeList { get; set; }
        public Decimal rebateDiscPercent { get; set; }
        public Decimal rebateDiscAmt { get; set; }
        public Decimal fixAmt { get; set; }
        public Boolean allPrdt { get; set; }
        public Decimal qty { get; set; }
        public Decimal price { get; set; }
        public Boolean isPouring { get; set; }
        public Decimal investmentValue { get; set; }
        public String paymentCondition { get; set; }
        public Decimal referencePrice { get; set; }
    }
    
    public virtual class ASI_HK_CRM_SKU {
        public String id { get; set; }
        public String code { get; set; }
        public String name { get; set; }
        public String subBrandName { get; set; }
        public String subBrandId { get; set; }
        public String subBrandCode { get; set; }
        public String brandType { get; set; }
        public Decimal basePrice { get; set; }
        public Decimal stdBottleSize { get; set;}
        public String itemGroupName { get; set; }
        public String itemGroupId { get; set; }
        public String pricingItem { get; set; }
        public Decimal referencePrice { get; set; }
        public Boolean allPrdt {get;set;} //20160317, added by Leo
    }
    
    public class ASI_HK_CRM_NormalProduct extends ASI_HK_CRM_SKU {
        public Decimal benchmark { get; set; }
        public Boolean showInProductList { get; set; }
        public Boolean active { get; set; }
    }
    
    public class ASI_HK_CRM_SaveResult {
        public Boolean success { get; set; }
        public List<String> messages { get; set; }
        
        public ASI_HK_CRM_SaveResult() {
            this.messages = new List<String>();
        }
    }
    
    private static Boolean isNonEmptyId(String theId) {
        if (theId != null && theId.trim() != '') {
            ID testId;
            try {
                testId = theId;
                return true;
            } catch(Exception e) {}
        }
        return false;
    }
    
}