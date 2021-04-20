public with sharing class ASI_CRM_HK_PAFApproval_EmailController {
	public Id currentHeaderID {get;set;}
    Public Boolean dummyVar{get{if(dummyVar != true){ dummyVar = init();} return dummyVar;} set;}
    public String testID {set;get;}
    public List<ASI_HK_CRM_Pre_Approval_Form_Mechanic__c > itemMechanics {get;set;}
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c  > lineItems {get;set;}
    
    
    //public final ASI_HK_CRM_Pre_Approval_Form__c paf              { get; set; }
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> fullLineList{ get; set; }
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> withDetailList { get; set; }
    public List<ASI_HK_CRM_Pre_Approval_Form_Item__c> skuWithDetails{ get; set;}
    public List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> PAFCustomer{ get; set;} 
    public List<ASI_HK_CRM_ProAndDetail> proAndDetailList{ get; set; }
    public List<CustomSKUMechanicDetail> CustomSKUMechanicDetailsList{ get; set; }
    public Map<String,Decimal> summaryMap{get;set;}
    public Map<String,String> summaryConditionMap{ get; set; }
    public Map<Boolean, String> yesnoMap{ get; set;}
    public Map<String,String> summaryFreeSKU {get;Set;} 
    public ASI_HK_CRM_ProAndDetail pad;
    public CustomSKUMechanicDetail cmd;
    public summaryMechanic sm;
    public boolean hasFOC = false;
    public String currencyDisplay{get; set;} 
    public Set<String> skuSet;
    
    public ASI_CRM_HK_PAFApproval_EmailController()
    {
         
               
    }
    public Boolean init(){
        
        system.debug('ASI_CRM_HK_PAFApproval_EmailController: ' + currentHeaderID);

      
       fullLineList = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
            requiredLineFields()
            , 'ASI_HK_CRM_Pre_Approval_Form_Item__c'
            , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__c =:currentHeaderID'
            , 'ORDER BY ASI_CRM_HK_Pricing_Item__c'
 
        ));
        
        withDetailList = (List<ASI_HK_CRM_Pre_Approval_Form_Item__c>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
            requiredLineFields()
            , 'ASI_HK_CRM_Pre_Approval_Form_Item__c'
            , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__c =:currentHeaderID'
            , 'ORDER BY ASI_HK_CRM_Mechanic__r.name'
        ));
		
        summaryMap = new Map<String,Decimal>();
  		summaryConditionMap = new Map<String, String>();
        summaryFreeSKU = new Map<String, String>();
        yesnoMap = new Map<Boolean,String>();
        yesnoMap.put(TRUE, 'Yes');
        yesnoMap.put(FALSE, 'NO');
            
        if(fullLineList.size() > 0){
            Set<String> skuSet = new Set<String>(); 
            proAndDetailList = new List<ASI_HK_CRM_ProAndDetail>();
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c paf_item : fullLineList){
               
                String tempComment = paf_item.ASI_HK_CRM_Conditions_for_Payment__c;
                if(paf_item.ASI_HK_CRM_Conditions_for_Payment__c == null){
                    tempComment = ' ';
                }
                
                
                summaryConditionMap.put(paf_item.ASI_HK_CRM_Mechanic__r.Name, tempComment);
                currencyDisplay = paf_item.currencyIsoCode;
                pad = new ASI_HK_CRM_ProAndDetail();
               
                pad.paf_displayItem = paf_item;
                if(paf_item.ASI_HK_CRM_Price__c != null) pad.priceShowDollarSign = true;
                if(paf_item.ASI_HK_CRM_SKU_Value__c != null) pad.skuValueShowDollarSign = true;
                
                
                if(paf_item.ASI_HK_CRM_Pouring__c)
                 pad.isPouring = TRUE;
                else
                 pad.isPouring = FALSE;
                
                
                
                if(!skuSet.contains(paf_item.ASI_HK_CRM_SKU_Lookup__r.Name))
                	proAndDetailList.add(pad);
				
                skuSet.add(paf_item.ASI_HK_CRM_SKU_Lookup__r.Name);          
               
                //system.debug(paf_item.ASI_HK_CRM_Mechanic__r.Name);
                
                //Summary of mechanic
                if(paf_item.ASI_HK_CRM_Mechanic__r.Name != null && paf_item.ASI_HK_CRM_Investment_Value__c != null){
                    pad = new ASI_HK_CRM_ProAndDetail();
                    sm = new summaryMechanic(); 
                    summaryMap.get(paf_item.ASI_HK_CRM_Mechanic__r.Name);
                    if(summaryMap.get(paf_item.ASI_HK_CRM_Mechanic__r.Name) == null){
                    //if (true) {
                        //String valueWithSign = String.valueOf(paf_item.CurrencyIsoCode) + ' ' + String.valueOf(paf_item.ASI_HK_CRM_Investment_Value__c);
                        
                        summaryMap.put(paf_item.ASI_HK_CRM_Mechanic__r.Name, paf_item.ASI_HK_CRM_Investment_Value__c);
                        if (paf_item.ASI_CRM_HK_Free_SKU__c == null)
                        	summaryFreeSKU.put(paf_item.ASI_HK_CRM_Mechanic__r.Name, '');
                    	else
                            summaryFreeSKU.put(paf_item.ASI_HK_CRM_Mechanic__r.Name, paf_item.ASI_CRM_HK_Free_SKU__r.Name);
						
                    }
                    
                    else{
                        //String retValue = summaryMap.get(paf_item.ASI_HK_CRM_Mechanic__r.Name);
                        //Decimal originValue = Decimal.valueOf();
                        //originValue += paf_item.ASI_HK_CRM_Investment_Value__c;
                        
                        summaryMap.put(paf_item.ASI_HK_CRM_Mechanic__r.Name, summaryMap.get(paf_item.ASI_HK_CRM_Mechanic__r.Name) + paf_item.ASI_HK_CRM_Investment_Value__c);
						
                        
                    }
                    
                }
                
            }
        }
        
        if(withDetailList.size() > 0){
            CustomSKUMechanicDetailsList = new List<CustomSKUMechanicDetail>();
 
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c paf_detail: withDetailList){ 
                Decimal targetVolume = paf_detail.ASI_HK_CRM_Target_Volume_Qty__c;
                Decimal price = paf_detail.ASI_HK_CRM_Price__c;
                
                if(paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - Variable' 
                || paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - Fixed Amount'){
                    cmd = new CustomSKUMechanicDetail();
                    cmd.paf_displaySKU = paf_detail;
                    cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                    cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                    cmd.sku_code = paf_detail.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c;
                    cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                    cmd.pricing_item = paf_detail.ASI_CRM_HK_Pricing_Item__c; // Added Pricing Item 20151218
                    cmd.buy_bottle = null;
                    cmd.sell_bottle = null;
                    cmd.investmentValue = paf_detail.ASI_HK_CRM_Investment_Value__c;
                    if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;  
                    if(paf_detail.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null) cmd.perBtShowDollarSign = true;              
                    CustomSKUMechanicDetailsList.add(cmd);       
                }
                //FOC and bulk FOC           
                else if(paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - FOC'  
                || paf_detail.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c == 'PAF Item - FOC Bulk'){
                    cmd = new CustomSKUMechanicDetail();
                    cmd.paf_displaySKU = paf_detail;
                    
                    if(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null){
                        cmd = new CustomSKUMechanicDetail();
                        cmd.paf_displaySKU = paf_detail;
                        cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                        cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                        cmd.sku_code = paf_detail.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c;
                        cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                        cmd.pricing_item = paf_detail.ASI_CRM_HK_Pricing_Item__c; // Added Pricing Item 20151218
                        cmd.buy_bottle = paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c;
                        cmd.sell_bottle = paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c;
                        if(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c != null 
                           && paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c == null)
                            cmd.investmentValue = getInvestmentValue(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c,
                                                                     paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c,
                                                                     targetVolume, price);
                        else
                            cmd.investmentValue = getInvestmentValue2(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_1__c,
                                                                      paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_1__c,
                                                                      targetVolume, price,
                                                                      paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c,
                                                                      paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c);
                        if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;
                        hasFOC = true;
                        CustomSKUMechanicDetailsList.add(cmd);
                    }
                    if(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c != null){
                        cmd = new CustomSKUMechanicDetail();
                        cmd.paf_displaySKU = paf_detail;
                        if(!hasFOC){
                            cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                            cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                            cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                        }
                        cmd.buy_bottle = paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c;
                        cmd.sell_bottle = paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c;
                        cmd.investmentValue = getInvestmentValue(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_2__c,
                        paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_2__c,
                        targetVolume, price);
                        if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;
                        CustomSKUMechanicDetailsList.add(cmd);
                    }
                    if(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c != null){
                        cmd = new CustomSKUMechanicDetail();
                        cmd.paf_displaySKU = paf_detail;
                        cmd.pricing_item = paf_detail.ASI_CRM_HK_Pricing_Item__c; // Added Pricing Item 20151218
                        if(!hasFOC){
                            cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                            cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                            cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                        }
                        cmd.buy_bottle = paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c;
                        cmd.sell_bottle = paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c;
                        cmd.investmentValue = getInvestmentValue(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_3__c,
                        paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_3__c,
                        targetVolume, price);
                        if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;
                        CustomSKUMechanicDetailsList.add(cmd);
                    }
                    if(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c != null){
                        cmd = new CustomSKUMechanicDetail();
                        cmd.paf_displaySKU = paf_detail;
                        cmd.pricing_item = paf_detail.ASI_CRM_HK_Pricing_Item__c; // Added Pricing Item 20151218
                        if(!hasFOC){
                            cmd.mechanic_name = paf_detail.ASI_HK_CRM_mechanic__r.Name;
                            cmd.Adj_Name = paf_detail.ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c;
                            cmd.sku_name = paf_detail.ASI_HK_CRM_SKU_Lookup__r.Name;
                        }
                        cmd.buy_bottle = paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c;
                        cmd.sell_bottle = paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c;
                        cmd.investmentValue = getInvestmentValue(paf_detail.ASI_HK_CRM_FOC_Buy_Bottle_Option_4__c,
                        paf_detail.ASI_HK_CRM_FOC_Free_Bottle_Option_4__c,
                        targetVolume, price);
                        if(cmd.investmentValue != null) cmd.investValueShowDollarSign = true;
                        CustomSKUMechanicDetailsList.add(cmd);
                    }                                   
                }
                

            }
        }
	    
        
        return true;
      
        
        
        
    }
    public class summaryMechanic{
        decimal totalInvestmentValue{ get; set;}
        boolean showDollarSign{ get; set; }
    }
    public class ASI_HK_CRM_ProAndDetail {
        public ASI_HK_CRM_Pre_Approval_Form_Item__c paf_displayItem{ get; set; }
        public boolean isPouring { get; set; }
        public boolean skuValueShowDollarSign{ get; set;}
        public boolean priceShowDollarSign{ get; set; }
        
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
    private static Set<String> requiredLineFields() {
        return new Set<String> {
            'Id'
            , 'ASI_HK_CRM_SKU_Lookup__r.Name'
            , 'ASI_HK_CRM_SKU_Lookup__c'
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.Name' // Added Sub-Brand 20180420'
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_FOC_Packing_Description__c'
            , 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c'
            , 'ASI_CRM_HK_Pricing_Item__c' 
            , 'ASI_CRM_HK_Free_SKU__r.Name' 
            , 'ASI_HK_CRM_Target_Volume_Qty__c'
            , 'ASI_HK_CRM_Price__c'
            , 'ASI_HK_CRM_Pouring__c'
            , 'ASI_HK_CRM_SKU_Value__c'
            , 'ASI_HK_CRM_Conditions_for_Payment__c'
            , 'ASI_HK_CRM_mechanic__r.Name'
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
            , 'ASI_HK_CRM_Rebate_Disc_Percent__c'
            , 'ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c'
            , 'CurrencyIsoCode'
            , 'ASI_HK_CRM_Mechanic__r.ASI_CRM_Adjustment_Name__c'
            
        };
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

 
    
    
}