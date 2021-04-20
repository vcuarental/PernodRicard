/***************************************************************************************************************************
 * Name: ASI_HK_CRM_PAF_CustomView
 * Description: 
 * Test Class: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-06-12       Wilken Lee              [WL 1.0] Show Pricing Issue checkbox in PAF page for KA PAF
 * 2020-06-12       PRA COE                 [COE 1.0] Changes of Net of On-Invoice Price 
 ****************************************************************************************************************************/
public class ASI_HK_CRM_PAF_CustomView {
    
    public final ASI_HK_CRM_Pre_Approval_Form__c paf              { get; set; }
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> fullLineList{ get; set; }
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> withDetailList { get; set; }
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> skuWithDetails{ get; set;}
    public List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustomer{ get; set;} // Added By Alan Wong (Elufa) 20150924
    public List<ASI_HK_CRM_ProAndDetail> proAndDetailList{ get; set; }
    public List<CustomSKUMechanicDetail> CustomSKUMechanicDetailsList{ get; set; }
    public List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mechanics { get; set; } 
    public List<MechanicGroup> mechanicGroupList { get; set; }
    public Map<String,Decimal> summaryMap{get;set;}
    public Map<String,String> summaryConditionMap{ get; set; }
    public Map<String,String> summaryFreeSKU {get;Set;} // Added by Ray Ui 20160113
    public ASI_HK_CRM_ProAndDetail pad;
    public CustomSKUMechanicDetail cmd;
    public List<summaryMechanic> summaryList { get; set; }
    public boolean hasFOC = false;
    public String currencyDisplay{get; set;} 
    public String editViewURL { get; set; }
    public Set<String> skuSet;
    public Map<String, Set<Integer>> groupMap;
    public Boolean showCustList {get; set; }
    
    public static final Integer BOTTLE_NUMBER = 4; 
    public static final String BUY_HEAD_FIELD = 'ASI_HK_CRM_FOC_Buy_Bottle_Option_{0}__c';
    public static final String SELL_HEAD_FIELD = 'ASI_HK_CRM_FOC_Free_Bottle_Option_{0}__c';
    public Map<Id,Decimal> skuCost =new Map<Id,Decimal>();

    
    private Set<String> pafAllFields;
    
    public void CheckNNP() {
        //&&*/ this.paf.ASI_HK_CRM_Items_NNP_LessThan_0__c == true
        if(this.paf.ASI_HK_CRM_PAF_Status__c == 'Draft' ){
            try{
                update this.paf;
            }catch(DmlException e){
                system.debug(e.getMessage());  
            }
        }
            
    }
    
    private static Set<String> requiredLineFields() {
        return new Set<String> {
            'Id'
            , 'ASI_CRM_HK_All_Product__c'
            , 'ASI_HK_CRM_SKU_Lookup__r.Name'
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.Name' // Added Sub-Brand 20180420'
            , 'ASI_HK_CRM_SKU_Lookup__c'
            , 'ASI_HK_CRM_Pricing_Issue__c' //WL 1.0
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_FOC_Packing_Description__c'
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c'
            , 'ASI_CRM_HK_Pricing_Item__c' // Added Pricing Item 20151218
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Sub_brand__r.Name' // Mark@ssc 20180808
            , 'ASI_CRM_HK_Free_SKU__r.Name' //Added 20160113
            , 'ASI_HK_CRM_Target_Volume_Qty__c'
            , 'ASI_HK_CRM_Price__c'
            , 'ASI_HK_CRM_Pouring__c'
            , 'ASI_HK_CRM_SKU_Value__c'
            , 'ASI_HK_CRM_Conditions_for_Payment__c'
            , 'ASI_HK_CRM_mechanic__r.Name'
            , 'ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c'
            , 'ASI_HK_CRM_mechanic__r.ASI_CRM_Short_Name__c'
            , 'ASI_HK_CRM_Investment_Value__c'
            , 'ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c'
            , 'ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c'
            , 'ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c'
            , 'ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c'
            , 'ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_1__c'
            , 'ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_2__c'
            , 'ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_3__c'
            , 'ASI_HK_CRM_FOC_Bulk_Buy_Bottle_Option_4__c'
            , 'ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_1__c'
            , 'ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_2__c'
            , 'ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_3__c'
            , 'ASI_HK_CRM_FOC_Bulk_Free_Bottle_Option_4__c'
            , 'ASI_HK_CRM_FOC_Free_Bottle_Option_1__c'
            , 'ASI_HK_CRM_FOC_Free_Bottle_Option_2__c'
            , 'ASI_HK_CRM_FOC_Free_Bottle_Option_3__c'
            , 'ASI_HK_CRM_FOC_Free_Bottle_Option_4__c'
            , 'ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c'
            , 'ASI_HK_CRM_Fixed_Amount__c'
            , 'ASI_HK_CRM_Rebate_Disc_Percent__c'
            , 'ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c'
            , 'CurrencyIsoCode'
            , 'ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c'
            
        };
    }
    
    public ASI_HK_CRM_PAF_CustomView (ApexPages.StandardController stdController){ 
        //this.paf = (ASI_HK_CRM_Pre_Approval_Form__c)stdController.getRecord();
        Id pafId = apexpages.currentPage().getParameters().get('id');
        this.editViewURL = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
        summaryConditionMap = new Map<String, String>();
        proAndDetailList = new List<ASI_HK_CRM_ProAndDetail>();
        skuSet = new Set<String>();
        groupMap = new Map<String, Set<Integer>>();
        CustomSKUMechanicDetailsList = new List<CustomSKUMechanicDetail>();
        mechanicGroupList = new List<MechanicGroup>();
        summaryMap = new Map<String,Decimal>();
        summaryList = new List<summaryMechanic>();
        pafAllFields = ASI_HK_CRM_CommonUtils.allFieldsOfSObject('ASI_HK_CRM_Pre_Approval_Form__c');
        pafAllFields.add('ASI_HK_CRM_PAF_Customer__r.ASI_HK_CRM_Customer_Code__c'); // Added By Alan Wong (Elufa) 20150924
        showCustList = false;
        this.paf = (ASI_HK_CRM_Pre_Approval_Form__c)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
            pafAllFields
            , 'ASI_HK_CRM_Pre_Approval_Form__c'
            , 'id =: pafId'
        ));
        //if(this.paf.ASI_HK_CRM_PAF_Status__c == 'Draft')
            this.paf.ASI_HK_CRM_Items_NNP_LessThan_0__c = False;
        retrieveFullLineList(pafId);
        //if(/*this.paf.ASI_HK_CRM_PAF_Status__c == 'Draft' &&*/ this.paf.ASI_HK_CRM_Items_NNP_LessThan_0__c == true)
            //update this.paf;
    }
    
    private void retrieveFullLineList(Id pafId){
        fullLineList = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
            requiredLineFields()
            , 'ASI_HK_CRM_Pre_Approval_Form_Item__c'
            , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__c =: pafId'
            , 'ORDER BY ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.Name asc,ASI_CRM_HK_Pricing_Item__c' // Sort by Sub-brand 20180420
            //,'ORDER BY ASI_CRM_HK_Pricing_Item__c'
            //TODO: Add "Order by" the item name
        ));
        
        withDetailList = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
            requiredLineFields()
            , 'ASI_HK_CRM_Pre_Approval_Form_Item__c'
            , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__c =: pafId'
            //, 'ORDER BY ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.Name asc,ASI_HK_CRM_Mechanic__r.name' // Sort by Sub-brand 20180420
            //, 'ORDER BY ASI_HK_CRM_Mechanic__r.name'
            
        ));

        mechanics = [
            SELECT Id, Name, ASI_HK_CRM_Mechanic_Category__c, ASI_HK_CRM_Mechanic_Type__c, ASI_HK_CRM_Code__c, ASI_CRM_Short_Name__c, ASI_CRM_HK_Active__c
            FROM ASI_HK_CRM_Pre_Approval_Form_Mechanic__c 
            order by ASI_HK_CRM_Code__c];

        //Added By Alan Wong (Elufa) 20150924
        if (this.paf.ASI_CRM_Short_Term_Promotion__c){ 
            showCustList = true;
            Set<String> fields = new Set<string>();
            fields.add('id');
            fields.add('name');
            fields.add('ASI_CRM_HK_Customer__c');
            fields.add('ASI_CRM_HK_Customer__r.Name');
            fields.add('ASI_CRM_Generate_Price_Set__c');
            fields.add('ASI_CRM_PA_DA__c');
            fields.add('ASI_CRM_HK_Customer__r.ParentId'); //20160628, edited by Leo
            fields.add('ASI_CRM_HK_Customer__r.Parent.Name'); //20160628, edited by Leo
            PAFCustomer = (List<ASI_CRM_HK_Pre_Approval_Form_Customer__c>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
                fields
                , 'ASI_CRM_HK_Pre_Approval_Form_Customer__c'
                , 'ASI_CRM_HK_Pre_Approval_Form__c =: pafId'
            ));
        }
        // End //
        if(fullLineList.size() > 0){
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c paf_item : fullLineList){
                String tempComment = paf_item.ASI_HK_CRM_Conditions_for_Payment__c;
                if(paf_item.ASI_HK_CRM_Conditions_for_Payment__c == null){
                    tempComment = ' ';
                }
                summaryConditionMap.put(paf_item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c, tempComment);
                currencyDisplay = paf_item.currencyIsoCode;
                pad = new ASI_HK_CRM_ProAndDetail();
                pad.paf_displayItem = paf_item;
                if(paf_item.ASI_HK_CRM_Price__c != null) pad.priceShowDollarSign = true;
                if(paf_item.ASI_HK_CRM_SKU_Value__c != null) pad.skuValueShowDollarSign = true;
                
                if(paf_item.ASI_HK_CRM_Pouring__c)
                 pad.isPouring = true;
                else
                 pad.isPouring = false;
                if(!skuSet.contains(paf_item.ASI_HK_CRM_SKU_Lookup__r.Name) && paf_item.ASI_CRM_HK_All_Product__c == false)
                    proAndDetailList.add(pad);

                skuSet.add(paf_item.ASI_HK_CRM_SKU_Lookup__r.Name);
                //Summary of mechanic
                if(paf_item.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c != null && paf_item.ASI_HK_CRM_Investment_Value__c != null)
                {
                    if (summaryMap.get(paf_item.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c) == null)
                    {
                        summaryMap.put(paf_item.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c, paf_item.ASI_HK_CRM_Investment_Value__c);
                    }
                    else
                    {
                        summaryMap.put(paf_item.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c, summaryMap.get(paf_item.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c) + paf_item.ASI_HK_CRM_Investment_Value__c);   
                    }
                }

                Set<Integer> pGroups = groupMap.get(paf_item.ASI_HK_CRM_SKU_Lookup__r.Name);
                if (pGroups == null)
                {
                    pGroups = new Set<Integer>();
                }

                Integer pGroup = getGroup(paf_item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c);
                if (!pGroups.contains(pGroup))
                {
                    pGroups.add(pGroup);
                }

                groupMap.put(paf_item.ASI_HK_CRM_SKU_Lookup__r.Name, pGroups);
            }
        }

        Decimal allPercent = 0;
        Decimal allDisc = 0;
        Decimal discAllPercent = 0;
        Decimal discAllAmount = 0;
        Decimal rebateAllPercent = 0;
        Decimal rebateAllAmount = 0;

        for (ASI_HK_CRM_Pre_Approval_Form_Item__c item : fullLineList)
        {
            if (item.ASI_CRM_HK_All_Product__c)
            {
                if (item.ASI_HK_CRM_Rebate_Disc_Percent__c != null)
                {
                    allPercent += item.ASI_HK_CRM_Rebate_Disc_Percent__c;
                }
                else if (item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null)
                {
                    allDisc += item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                }

                if (item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A01')
                {
                    if (item.ASI_HK_CRM_Rebate_Disc_Percent__c != null)
                    {
                        discAllPercent = item.ASI_HK_CRM_Rebate_Disc_Percent__c;
                    }
                    else if (item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null)
                    {
                        discAllAmount = item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                    }
                }
                else if (item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A08')
                {
                    if (item.ASI_HK_CRM_Rebate_Disc_Percent__c != null)
                    {
                        rebateAllPercent = item.ASI_HK_CRM_Rebate_Disc_Percent__c;
                    }
                    else if (item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null)
                    {
                        rebateAllAmount = item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                    }
                }
            }
        }

        for (ASI_HK_CRM_ProAndDetail pd : proAndDetailList)
        {
            List<ASI_HK_CRM_Pre_Approval_Form_Item__c> itemList = getItems(fullLineList, pd.paf_displayItem.ASI_HK_CRM_SKU_Lookup__r.Name);

            Decimal totalInvest = 0;
            Decimal investBottle = 0;
            Decimal targetVolume = 0;
            Decimal freeVolume = 0;
            Decimal price = 0; 
            pd.targetRevenue = 0;
            pd.invoiceDisc = 0;
            pd.netInvoicePrice = 0;
            pd.earlyDisc = 0;
            pd.netEarlyPrice = 0;
            pd.rebate = 0;
            pd.rebateAll = 0;
            pd.netPrice = 0;
            pd.targetNetRevenue = 0;
            
            Decimal nnpFactor = 0; 
            Decimal nnpFactorPercent=0;

            for (ASI_HK_CRM_Pre_Approval_Form_Item__c item : itemList){
                if (price == 0 && item.ASI_HK_CRM_Price__c != null){
                    price = item.ASI_HK_CRM_Price__c;
                }
                if (item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A04'){
                    if (item.ASI_HK_CRM_Rebate_Disc_Percent__c != null && item.ASI_HK_CRM_Rebate_Disc_Percent__c > 0){
                        pd.invoiceDisc = (price * item.ASI_HK_CRM_Rebate_Disc_Percent__c / 100);
                    }

                    if (item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null && item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c > 0){
                         pd.invoiceDisc = item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                    }
                }
            }
            
            //Net of On-Invoice Price 
            pd.netInvoicePrice = price - pd.invoiceDisc;
            
            for (ASI_HK_CRM_Pre_Approval_Form_Item__c item : itemList){
                
                if ( item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c =='A17' ||item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A09' ||item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c =='A06'||
                        item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c =='A12'||item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A14'||item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c =='B01'){
                            
                    if(item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c != 'A06')
                        nnpFactor+= ((item.ASI_HK_CRM_Investment_Value__c==null?0:item.ASI_HK_CRM_Investment_Value__c )/item.ASI_HK_CRM_Target_Volume_Qty__c);
                    else if (item.ASI_HK_CRM_Rebate_Disc_Percent__c!=null)
                        nnpFactorPercent=item.ASI_HK_CRM_Rebate_Disc_Percent__c;
                    else 
                        nnpFactor+= item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                            
                }
                /*
                if (item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A06' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A09' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A17' || 
                    item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A12' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A14' ||
                    item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B01' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B02' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B03' ||
                    item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B05' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B06' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B07' ||
                    item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B04' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B09' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B10' ||item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B11'
                    ){
                    
                    if(item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c != 'A06')
                        nnpFactor+= (item.ASI_HK_CRM_Investment_Value__c==null?0:item.ASI_HK_CRM_Investment_Value__c );
                    else
                        nnpFactorPercent=item.ASI_HK_CRM_Rebate_Disc_Percent__c;

                }
                */
                
                if (targetVolume == 0 && item.ASI_HK_CRM_Target_Volume_Qty__c != null){
                    targetVolume = item.ASI_HK_CRM_Target_Volume_Qty__c;
                }
                
                if (price == 0 && item.ASI_HK_CRM_Price__c != null){
                   
                    if (allPercent > 0){
                        totalInvest += (targetVolume * (this.paf.ASI_CRM_HK_Calculate_on_Net_Price__c? pd.netInvoicePrice : price) * (allPercent / 100));// price -= (price * allPercent / 100);
                    }
                    if (allDisc > 0) {
                        totalInvest += (targetVolume * allDisc);// price -= allDisc;
                    }
                }
                if (item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A04'
                    || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A02' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'B01'
                    || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A03' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A11' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A17'
                    || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A07' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A09'
                    || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A06' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A10' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A12'
                    || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A14' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A15' || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A16')
                {
                    totalInvest += (item.ASI_HK_CRM_Investment_Value__c != null ? item.ASI_HK_CRM_Investment_Value__c : 0);
                }
                
                if (item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A02'
                    || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A03'
                    || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A11'
                    || item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A17')
                {
                    investBottle += ((item.ASI_HK_CRM_Investment_Value__c != null ? item.ASI_HK_CRM_Investment_Value__c : 0) / price);
                }

                if (item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A02'){
                    pd.buyGetBottle = new List<BuyGetBottle>();

                    if (item.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null || item.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c != null){
                        BuyGetBottle newBG = new BuyGetBottle();
                        newBG.buy = item.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c;
                        newBG.get = item.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c;
                        pd.buyGetBottle.add(newBG);
                        if(item.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c!=0 ){
                            freeVolume += (targetVolume/item.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c) * item.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c;
                        }
                    }
                    
                    if (item.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null || item.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c != null){
                        BuyGetBottle newBG = new BuyGetBottle();
                        newBG.buy = item.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c;
                        newBG.get = item.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c;
                        pd.buyGetBottle.add(newBG);
                        if(item.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c!=0 ){
                            freeVolume += (targetVolume/item.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c) * item.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c;
                        }
                    }

                    if (item.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c != null || item.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c != null){
                        BuyGetBottle newBG = new BuyGetBottle();
                        newBG.buy = item.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c;
                        newBG.get = item.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c;
                        pd.buyGetBottle.add(newBG);
                        if(item.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c!=0 ){
                            freeVolume += (targetVolume/item.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c) * item.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c;
                        }
                    }

                    if (item.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c != null || item.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c != null){
                        BuyGetBottle newBG = new BuyGetBottle();
                        newBG.buy = item.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c;
                        newBG.get = item.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c;
                        pd.buyGetBottle.add(newBG);
                        if(item.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c!=0 ){
                            freeVolume += (targetVolume/item.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c) * item.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c;
                        }
                    }
                }else if (item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == 'A07'){
                    if (item.ASI_HK_CRM_Rebate_Disc_Percent__c != null && item.ASI_HK_CRM_Rebate_Disc_Percent__c > 0){
                        if(!this.paf.ASI_CRM_HK_Calculate_on_Net_Price__c)
                            pd.rebate = (price * item.ASI_HK_CRM_Rebate_Disc_Percent__c / 100);
                        else    
                            pd.rebate = (pd.netInvoicePrice  * item.ASI_HK_CRM_Rebate_Disc_Percent__c / 100);  // (price * item.ASI_HK_CRM_Rebate_Disc_Percent__c / 100);
                    }

                    if (item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null && item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c > 0) {
                        pd.rebate = item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                    }
                }
            }

            //Rebates (All Products)
            if (rebateAllPercent > 0){
                pd.rebateAll = ((this.paf.ASI_CRM_HK_Calculate_on_Net_Price__c? pd.netInvoicePrice : price) * rebateAllPercent / 100);  //(price * rebateAllPercent / 100);
            }else if (rebateAllAmount > 0){
                pd.rebateAll = rebateAllAmount;
            }
            
            //Net of Early Payment Disc. 
            if (discAllPercent > 0){
                pd.earlyDisc =((this.paf.ASI_CRM_HK_Calculate_on_Net_Price__c? pd.netInvoicePrice : price) * discAllPercent / 100);//(price * discAllPercent / 100);
            }
            else if (discAllAmount > 0)
            {
                pd.earlyDisc = discAllAmount;
            }

System.debug('pd.paf_displayItem.ASI_HK_CRM_SKU_Lookup__r.Name,targetVolume,investBottle,price,totalInvest');
System.debug(pd.paf_displayItem.ASI_HK_CRM_SKU_Lookup__r.Name+','+targetVolume+','+investBottle+','+price+','+totalInvest);

            Decimal totalBottle = targetVolume + investBottle;
            Decimal grossSales = totalBottle * price;
            Decimal netSales = grossSales - totalInvest;
            Decimal nnp = totalBottle == 0 ? 0 : netSales / totalBottle;
            pd.targetRevenue = price * targetVolume;
            
            pd.netEarlyPrice = price - pd.invoiceDisc - pd.earlyDisc;
            Decimal netPrice = (price - pd.invoiceDisc - pd.earlyDisc - pd.rebate - pd.rebateAll)*targetVolume / (targetVolume + freeVolume);
            pd.netPrice = netPrice;
            pd.targetNetRevenue = pd.netPrice * targetVolume;
            pd.nnp = nnp;
            
            //System.debug('pd.nnp');
            System.debug('netPrice : '+netPrice+ ',nnpFactor :'+nnpFactor+',netInvoicePrice : '+ pd.netInvoicePrice + ',nnpFactorPercent : '+nnpFactorPercent );

            pd.nnp = netPrice-nnpFactor-(nnpFactorPercent==null ||nnpFactorPercent==0?0: pd.netInvoicePrice*nnpFactorPercent/100);
            if(pd.nnp<0)
                this.paf.ASI_HK_CRM_Items_NNP_LessThan_0__c = true;
            else
                this.paf.ASI_HK_CRM_Items_NNP_LessThan_0__c = false;
        }
        
        for (Integer i = 1; i <= 5; i++)
        {
            if (i == 2)
            {
                continue;
            }
            MechanicGroup mGroup = new MechanicGroup();

            if (i == 1)
            {
                mGroup.name = 'SPTD - For All Product by Price Set';
            }
            else if (i == 2)
            {
                mGroup.name = 'SPTD - by Price Set';
            }
            else if (i == 3)
            {
                mGroup.name = 'SPTD by PO';
            }
            else if (i == 4)
            {
                mGroup.name = 'Trade A&P (Under Sales Budget)';
            }
            else if (i == 5)
            {
                mGroup.name = 'Trade A&P (Under CM/ TM)';
            }

            mGroup.columns = new List<MechanicColumn>{
                //new MechanicColumn('Sub-brand', ''),
                new MechanicColumn('Pricing Item', ''),
                new MechanicColumn('Target Qty (BT)', ''),
                new MechanicColumn('Gross Price (HKD)', ''),
                new MechanicColumn('Investment', '')
            };

            List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> groupMechs = getGroupMechanics(i);
            Set<String> groupProducts = getGroupProducts(i);

            List<MechanicLine> newLines = new List<MechanicLine>();
            for (String key : groupProducts)
            {
                ASI_HK_CRM_ProAndDetail pd = getProductDetail(key);
                MechanicLine newLine = new MechanicLine();
                newLine.id = key;
                newLine.subBrand = '';
                newLine.pricingItem  = '';
                newLine.targetVolume = 0;
                newLine.price = 0;
                newLine.investmentValue = 0;
                newLine.mechanicItems = new List<MechanicItem>();
                newLines.add(newLine);
            }

            for (ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech : groupMechs)
            {
                MechanicColumn col = new MechanicColumn(mech.ASI_CRM_Short_Name__c, '');
                mGroup.columns.add(col);

                for (String key : groupProducts)
                {
                    MechanicLine line = getLine(newLines, key);
                    ASI_HK_CRM_Pre_Approval_Form_Item__c item = getItemByCode(withDetailList, key, mech.ASI_HK_CRM_Code__c);
                    
                    MechanicItem newItem = new MechanicItem();

                    if (item != null)
                    {
                        newItem.investmentValue = item.ASI_HK_CRM_Investment_Value__c;
                        newItem.buyGetBottle = new List<BuyGetBottle>();
                        newItem.rebatePercent = item.ASI_HK_CRM_Rebate_Disc_Percent__c;
                        newItem.rebateAmount = item.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                        newItem.fixedAmount = item.ASI_HK_CRM_Fixed_Amount__c;

                        if (item.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null || item.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c != null)
                        {
                            BuyGetBottle newBG = new BuyGetBottle();
                            newBG.buy = item.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c;
                            newBG.get = item.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c;
                            newItem.buyGetBottle.add(newBG);
                        }
                        
                        if (item.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null || item.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c != null)
                        {
                            BuyGetBottle newBG = new BuyGetBottle();
                            newBG.buy = item.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c;
                            newBG.get = item.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c;
                            newItem.buyGetBottle.add(newBG);
                        }

                        if (item.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c != null || item.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c != null)
                        {
                            BuyGetBottle newBG = new BuyGetBottle();
                            newBG.buy = item.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c;
                            newBG.get = item.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c;
                            newItem.buyGetBottle.add(newBG);
                        }

                        if (item.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c != null || item.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c != null)
                        {
                            BuyGetBottle newBG = new BuyGetBottle();
                            newBG.buy = item.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c;
                            newBG.get = item.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c;
                            newItem.buyGetBottle.add(newBG);
                        }

                        line.subBrand = item.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__r.ASI_MFM_Sub_brand__r.Name;
                        line.pricingItem = item.ASI_CRM_HK_Pricing_Item__c;
                        line.targetVolume = item.ASI_HK_CRM_Target_Volume_Qty__c;
                        line.price = item.ASI_HK_CRM_Price__c;
                        line.investmentValue += (item.ASI_HK_CRM_Investment_Value__c != null ? item.ASI_HK_CRM_Investment_Value__c : 0);
                    }
                    
                    line.mechanicItems.add(newItem);
                }
            }

            mGroup.lines = newLines;
            mechanicGroupList.add(mGroup);
        }

        for (ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech : mechanics)
        {
            if (summaryMap.get(mech.ASI_HK_CRM_Code__c) != null)
            {
                summaryMechanic sMec = new summaryMechanic();
                sMec.name = mech.ASI_CRM_Short_Name__c;
                sMec.investmentValue = summaryMap.get(mech.ASI_HK_CRM_Code__c);
                sMec.condition = summaryConditionMap.get(mech.ASI_HK_CRM_Code__c);
                summaryList.add(sMec);
            }
        }
    }

    public ASI_HK_CRM_ProAndDetail getProductDetail(String key)
    {
        for (ASI_HK_CRM_ProAndDetail pd : proAndDetailList)
        {
            if (pd.paf_displayItem.ASI_HK_CRM_SKU_Lookup__r.Name == key)
            {
                return pd;
            }
        }

        return null;
    }

    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> getItems(List<ASI_HK_CRM_Pre_Approval_Form_Item__c> itemList, String lookupName)
    {
        List<ASI_HK_CRM_Pre_Approval_Form_Item__c> retList = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();

        for (ASI_HK_CRM_Pre_Approval_Form_Item__c item : itemList)
        {
            if (item.ASI_HK_CRM_SKU_Lookup__r.Name == lookupName)
            {
                retList.add(item);
            }
        }

        return retList;
    }

    public ASI_HK_CRM_Pre_Approval_Form_Item__c getItemByCode(List<ASI_HK_CRM_Pre_Approval_Form_Item__c> itemList, String lookupName, String code)
    {
        ASI_HK_CRM_Pre_Approval_Form_Item__c ret;

        for (ASI_HK_CRM_Pre_Approval_Form_Item__c item : itemList)
        {
            if (item.ASI_HK_CRM_SKU_Lookup__r.Name == lookupName && item.ASI_HK_CRM_mechanic__r.ASI_HK_CRM_Code__c == code)
            {
                ret = item;
                break;
            }
        }

        return ret;
    }
    
    public class ASI_HK_CRM_ProAndDetail {
        public ASI_HK_CRM_Pre_Approval_Form_Item__c paf_displayItem{ get; set; }
        public boolean isPouring { get; set; }
        public boolean skuValueShowDollarSign{ get; set;}
        public boolean priceShowDollarSign{ get; set; }
        public Decimal targetRevenue { get; set; }
        public Decimal invoiceDisc { get; set; }
        public Decimal netInvoicePrice { get; set; }
        public Decimal earlyDisc { get; set; }
        public Decimal netEarlyPrice { get; set; }
        public List<BuyGetBottle> buyGetBottle { get; set; }
        public Decimal rebate { get; set; }
        public Decimal rebateAll { get; set; }
        public Decimal netPrice { get; set; }
        public Decimal targetNetRevenue { get; set; }
        public Decimal nnp { get; set; }
    }

    public class MechanicGroup {
        public String name { get; set; }
        public List<MechanicColumn> columns { get; set; }
        public List<MechanicLine> lines { get; set; }
    }

    public class MechanicColumn {
        public String name { get; set; }
        public String description { get; set; }
        
        public MechanicColumn(String name, String description)
        {
            this.name = name;
            this.description = description;
        }
    }

    public class MechanicLine {
        public String id { get; set; }
        public String subBrand { get; set; }
        public String pricingItem { get; set; }
        public Decimal targetVolume { get; set; }
        public Decimal price { get; set; }
        public Decimal investmentValue { get; set; }
        public List<MechanicItem> mechanicItems { get; set; }
    }

    public class BuyGetBottle {
        public Decimal buy { get; set; }
        public Decimal get { get; set; }
    }
    public class MechanicItem {
        public Decimal investmentValue { get; set; }
        public List<BuyGetBottle> buyGetBottle { get; set; }
        public Decimal rebatePercent { get; set; }
        public Decimal rebateAmount { get; set; }
        public Decimal fixedAmount { get; set; }
    }

    public class CustomSKUMechanicDetail{
        public ASI_HK_CRM_Pre_Approval_Form_Item__c paf_displaySKU{ get; set; }
        public String mechanic_name{ get; set; }
        public String pricing_item {get; set;} // Added Pricing Item 20151218
        public String sku_name{ get; set; }
        public String sku_code{ get; set; }
        public String Adj_Name{ get; set; } // Added by Alan Wong (Elufa) 20150916
        public Decimal buy_bottle{ get; set; }
        public Decimal sell_bottle{ get; set; }
        public Decimal investmentValue{ get; set; }
        public boolean investValueShowDollarSign{ get; set; }
        public boolean perBtShowDollarSign{ get; set; }
    }
    public class summaryMechanic
    {
        public String name { get; set; }
        public Decimal investmentValue { get; set; }
        public String condition { get; set; }
    }
    
    
    //return the name with index
    public String getBuyBottle(Integer index){
        return String.format(BUY_HEAD_FIELD, new String[]{String.valueOf(index)});
    }
    
    public String getSellBottle(Integer index){
        return String.format(SELL_HEAD_FIELD, new String[]{String.valueOf(index)});
    }
    
    public Decimal getInvestmentValue(Decimal buyBt, Decimal freeBt, Decimal volume, Decimal price){
        Decimal result; 
        Integer totalFreeBt;
        
        if(buyBt == null){
            return null;
        }
        else if(volume == null){
            return null;
        }
        else if(freeBt == null){
            return null;
        }
        else if(Price == null){
            return null;
        }
        
        totalFreeBt = Integer.valueOf(volume)/Integer.valueOf(buyBt);
        totalFreeBt = totalFreeBt * Integer.valueOf(freeBt);
        result = totalFreeBt * price;
        return result;
        
        
        
    }
    
    public Decimal getInvestmentValue2(Decimal buyBt, Decimal freeBt, Decimal volume, Decimal price, Decimal buyBt2, Decimal freeBt2){
        Decimal result; 
        Integer totalFreeBt;
        
        if(buyBt == null){
            return null;
        }
        else if(volume == null){
            return null;
        }
        else if(freeBt == null){
            return null;
        }
        else if(Price == null){
            return null;
        }
        else if(buyBt2 == null){
            return null;
        }
        else if(freeBt2 == null){
            return null;
        }
        
        totalFreeBt = Math.mod(Integer.valueOf(volume),Integer.valueOf(buyBt2));
        if(totalFreeBt > 0)
        {
            totalFreeBt = Integer.valueOf(totalFreeBt)/Integer.valueOf(buyBt);
            totalFreeBt = totalFreeBt * Integer.valueOf(freeBt);
            result = totalFreeBt * price;
        }//end if
        else
        {
            result = 0;
        }//end else
        return result;
    }
    
    public List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> getGroupMechanics(Integer g)
    {
        Set<String> orders;

        if (g == 1)
        {
            orders = new set<String>{
                'A01', 'A08'
            };
        }
        else if (g == 2)
        {
            orders = new set<String>{
                'A02', 'A04', 'A07'
            };
        }
        else if (g == 3)
        {
            orders = new set<String>{
                'A17', 'A09', 'A06', 'A12', 'A14', 'B01'//, 'A11', 'A05', 'A10', 'A15', 'A03', 'A16' //Howard @Introv 20200206 remove table col 
            };
        }
        else if (g == 4)
        {
            orders = new set<String>{
                'B03', 'B02', 'B07', 'B05', 'B06'
            };
            
        }
        else if (g == 5)
        {
            orders = new set<String>{
                'B08', 'B09', 'B04', 'B10', 'B11'
            };
            
        }
        
        List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c> mechs = new List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c>();

        for (String code : orders)
        {
            for (ASI_HK_CRM_Pre_Approval_Form_Mechanic__c mech : mechanics)
            {
                if (mech.ASI_HK_CRM_Code__c == code)
                {
                    mechs.add(mech);
                    break;
                }
            }
        }

        return mechs;
    }

    public Integer getGroup(String code)
    {
        if (code == 'A01'
            || code == 'A08')
        {
            return 1;
        }
        else if (code == 'A02'
            || code == 'A04'
            || code == 'A07')
        {
            return 2;
        }
        else if (code == 'A17'
            || code == 'A03'
            || code == 'A09'
            || code == 'A06'
            || code == 'A12'
            || code == 'A14'
            || code == 'B01'
            || code == 'A11'
            || code == 'A05'
            || code == 'A10'
            || code == 'A15'
            || code == 'A16')
        {
            return 3;
        }
        else if (code == 'B03'
            || code == 'B02'
            || code == 'B07'
            || code == 'B05'
            || code == 'B06')
        {
            return 4;
        }
        else if (code == 'B08'
            || code == 'B09'
            || code == 'B04'
            || code == 'B10'
            || code == 'B11')
        {
            return 5;
        }
        
        return 0;
    }

    public Set<String> getGroupProducts(Integer g)
    {
        Set<String> products = new Set<String>();

        for (String key : groupMap.keySet())
        {
            Set<Integer> groups = groupMap.get(key);

            if (groups.contains(g))
            {
                products.add(key);
            }
        }

        return products;
    }

    public MechanicLine getLine(List<MechanicLine> lines, String key)
    {
        MechanicLine retLine;
        for (MechanicLine line : lines)
        {
            if (line.id == key)
            {
                retLine = line;
                break;
            }
        }

        return retLine;
    }
}