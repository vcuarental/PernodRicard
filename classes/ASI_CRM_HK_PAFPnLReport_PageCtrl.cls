/*********************************************************************************
 * Name: ASI_CRM_HK_PAFPnLReport_PageCtrl
 * Description: Controller class for ASI_CRM_HK_PAFPnLReport_Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-05-02       Vincent Lam             Created       
*/
public class ASI_CRM_HK_PAFPnLReport_PageCtrl {
   
    public Id headerId {get; set;}
    public String pafId {get; set;}
    public String fileId;
    public String parentFileId;
    public Boolean isActualBreakdown {get; set;}
    public String returnFileId {get{return fileId;}}
    public String resultHTML {get; set;}


    public ASI_CRM_HK_PAFPnLReport_PageCtrl() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        pafId = params.get('id');
        fileId = params.get('fileId');
        isActualBreakdown = params.get('actual') != null ? Boolean.valueOf(params.get('actual')) : false;
        if(fileId != null){
            buildResult();
        } else {
            init();
        }
        
    }
    
    private class SKUWrapper{
        private string pafId {get;set;}
        /*
        private string customerId {get;set;}
        */
        private string skuId {get;set;}
        private decimal totalBottle {get;set;}
        private decimal totalBottleWithSTK {get;set;}
        private decimal price {get;set;}
        private decimal bottleSize {get;set;}
        private decimal volume9L {get;set;}
        private String SubBrandId  {get;set;}
        private String BrandId  {get;set;}
        private decimal onInvoiceDisc {get;set;}
        
        private SKUWrapper(string pafId, /*string customerId, */string skuId, decimal totalBottle, decimal price, decimal bottleSize, String SubBrandId,String BrandId){
            this.pafId = pafId;
            /*
            this.customerId = customerId;
            */
            this.skuId = skuId;
            this.totalBottle = totalBottle != null ? totalBottle : 0;
            this.totalBottleWithSTK = this.totalBottle;
            this.price = price != null ? price : 0;
            this.bottleSize = bottleSize != null ? bottleSize : 0;
            this.SubBrandId = SubBrandId;
            this.BrandId = BrandId;
            this.volume9L = 0;
            this.onInvoiceDisc=0;
        }
    }
    
    private class DetailWrapper{
        
        private List<ASI_HK_CRM_Pre_Approval_Form_Item__c> list_pafl {get;set;}
        private List<AggregateResult> PnL_Cost_List {get;set;} {PnL_Cost_List= new List<AggregateResult> ();}
        
        private Map<string, SKUWrapper> map_sku_skuW {get;set;}
        private Map<string, boolean> map_paf_includeVolume {get;set;}
        private String key {get;set;}
        private Date EndDate {get;set;}
        private decimal A01 {get;set;}
        private decimal A02 {get;set;}
        private decimal A03 {get;set;}
        private decimal A04 {get;set;}
        private decimal A05 {get;set;}
        private decimal A06 {get;set;}
        private decimal A07 {get;set;}
        private decimal A08 {get;set;}
        private decimal A09 {get;set;}
        private decimal A10 {get;set;}
        private decimal A11 {get;set;}
        private decimal A12 {get;set;}
        private decimal A13 {get;set;}
        private decimal A14 {get;set;}
        private decimal A15 {get;set;}
        private decimal A16 {get;set;}
        private decimal A17 {get;set;}
        private decimal B01 {get;set;}
        private decimal B02 {get;set;}
        private decimal B03 {get;set;}
        private decimal B04 {get;set;}
        private decimal B05 {get;set;}
        private decimal B06 {get;set;}
        private decimal B07 {get;set;}
        private decimal B08 {get;set;}
        private decimal B09 {get;set;}
        private decimal B10 {get;set;}
        private decimal B11 {get;set;}
        private decimal B12 {get;set;}
        private decimal B13 {get;set;}
        private decimal B14 {get;set;}
        private decimal SalesValue {get;set;}
        private decimal TotalInvestmentBeforeNetSales {get;set;}
        private decimal NetSales {get;set;}
        private decimal Cost {get;set;}
        private decimal CM {get;set;}
        private decimal TotalInvestmentAfterNetSales {get;set;}
        private decimal CAAP {get;set;}
        private decimal TotalInvestment {get;set;}
        private decimal TotalInvestmentPercentOfSalesValues {get;set;}
        private decimal ROIPercent {get;set;}
        private decimal VariableInvestment {get;set;}
        private decimal FixedInvestment {get;set;}
        private decimal Volume9L {get;set;}
        private decimal NNPper9L {get;set;}
        private Map<string, list<ASI_HK_CRM_Pre_Approval_Form_Item__c>> map_pafId_paflAllProduct {get;set;}
        private set<string> MechanicsNotSKU = new set<string>{'A01','A08'};
        
        private DetailWrapper(string key){
            this(key, null);
        }
        
        private DetailWrapper(string key, Map<string, boolean> map_paf_includeVolume){
            this.key = key;
            this.map_paf_includeVolume = map_paf_includeVolume;
            this.list_pafl = new List<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
            this.map_sku_skuW = new map<string, SKUWrapper>();
            resetNumbers();
        }
        
        public void clearAll(){
            /*
            this.MechanicsNotSKU = null;
            this.map_pafId_paflAllProduct = null;
            this.map_paf_includeVolume = null;
            this.map_sku_skuW = null;
            this.list_pafl = null;
            this.PnL_Cost_List = null;
            */
        }
        
        public void addPnLCostLine(AggregateResult PnLCostLine){
            this.PnL_Cost_List.add(PnLCostLine);
        }
        
        public void addLine(ASI_HK_CRM_Pre_Approval_Form_Item__c pafl){
            this.list_pafl.add(pafl);
            
            /*
            date inputDate = pafl.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c!=null?pafl.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c:date.today() ;
            
            Date LastDateOfThisFY = Date.newinstance(inputDate.year(), 6,30);
            if(inputDate.month() > 7){
                LastDateOfThisFY = LastDateOfThisFY.addYears(1);
            }
            this.EndDate=LastDateOfThisFY;
            */
        }
        private void resetNumbers(){
            A01 = 0;
            A02 = 0;
            A03 = 0;
            A04 = 0;
            A05 = 0;
            A06 = 0;
            A07 = 0;
            A08 = 0;
            A09 = 0;
            A10 = 0;
            A11 = 0;
            A12 = 0;
            A13 = 0;
            A14 = 0;
            A15 = 0;
            A16 = 0;
            A17 = 0;
            B01 = 0;
            B02 = 0;
            B03 = 0;
            B04 = 0;
            B05 = 0;
            B06 = 0;
            B07 = 0;
            B08 = 0;
            B09 = 0;
            B10 = 0;
            B11 = 0;
            B12 = 0;
            B13 = 0;
            B14 = 0;
            SalesValue = 0;
            TotalInvestmentBeforeNetSales = 0;
            NetSales = 0;
            Cost = 0;
            CM = 0;
            TotalInvestmentAfterNetSales = 0;
            CAAP = 0;
            TotalInvestment = 0;
            TotalInvestmentPercentOfSalesValues = 0;
            ROIPercent = 0;
            VariableInvestment = 0;
            FixedInvestment = 0;
            Volume9L = 0;
            NNPper9L = 0;
            
        }
        public void addAllProductLine(Map<string, list<ASI_HK_CRM_Pre_Approval_Form_Item__c>> map_pafId_paflAllProduct){
            this.map_pafId_paflAllProduct = map_pafId_paflAllProduct;
        }
        public void getSalesTarget(){
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafl : list_pafl){
                string skuId = pafl.ASI_HK_CRM_SKU_Lookup__c;
                string subBrandId = pafl.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c;
                string pafId = pafl.ASI_HK_CRM_Pre_Approval_Form_Lookup__c;
                string customerId = pafl.ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c;
                string key = pafId + '_' + subBrandId + '_' + skuId;
                if(skuId.startsWith('a7HM00000008RYr')){
                    system.debug(pafl.id);
                    system.debug(pafl.ASI_HK_CRM_Target_Volume_Qty__c);
                }
                if(!map_sku_skuW.containsKey(key) && !MechanicsNotSKU.contains(pafl.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c)){
                    SKUWrapper w = new SKUWrapper(pafId, /*customerId, */skuId, pafl.ASI_HK_CRM_Target_Volume_Qty__c,
                                                  pafl.ASI_HK_CRM_Price__c, 
                                                  pafl.ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_Std_Bottle_Size__c,pafl.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c,
                                                pafl.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c);
                    map_sku_skuW.put(key, w);
                }
                
                if(pafl.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c=='A04'){
                    SKUWrapper w=map_sku_skuW.get(key);
                    w.onInvoiceDisc=pafl.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                    map_sku_skuW.put(key, w);
                }
                
            }
        }
        public void getSalesTargetActual(){
            for(AggregateResult pnl :PnL_Cost_List){
                string subBrandId = String.valueOf(pnl.get('subBrandId'));
                string brandId = String.valueOf(pnl.get('brandId'));
                string key = subBrandId;
                if(!map_sku_skuW.containsKey(key)){
                    SKUWrapper w = new SKUWrapper(null, /*null, */null, 0,
                                                  0, 
                                                  0, subBrandId,
                                                 brandId);
                    map_sku_skuW.put(key, w);
                }
            }
        }
        
        public void calculationGroupByTypeActual(Map<String,ASI_CRM_PnL_Cost__c> PnLCostMap, date LastDateOfThisFY){
            for(AggregateResult PnLCost:PnL_Cost_List){
                string subBrandId = String.valueOf(PnLCost.get('subBrandId'));
                String ObjectKey = String.valueOf(PnLCost.get('ObjectKey'));
                String lineType = String.valueOf(PnLCost.get('lineType'));
                Decimal volume9LFromPnl = 0;
                Decimal value = 0;
                if(lineType =='V'){
                    SKUWrapper w = map_sku_skuW.get(subBrandId);
                    
                    volume9LFromPnl = -(Decimal)PnLCost.get('volume9L'); // the volume 9L in data source is -ve...
                    w.volume9L += volume9LFromPnl;
                    Volume9L += volume9LFromPnl;
                    
                    /*
                    Date LastDateOfLastFY = LastDateOfThisFY.addYears(-1);
                    Decimal CostPer9L=0;
                    if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfThisFY) )){
                        CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfThisFY)  ).ASI_CRM_Cost_per_9L_YTD__c;
                    }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfLastFY) )){
                        CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfLastFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                    }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Budget_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfThisFY) )){
                        CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Budget_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfThisFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                    }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfThisFY) )){
                        CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfThisFY)  ).ASI_CRM_Cost_per_9L_YTD__c;
                    }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfLastFY) )){
                        CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfLastFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                    }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Budget_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfThisFY) )){
                        CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Budget_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfThisFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                    }
                    
                    Cost += volume9LFromPnl * CostPer9L;
                    */
                }
                if(lineType =='A' || lineType =='T'){
                    value = (Decimal)PnLCost.get('value'); 
                    
                    if(ObjectKey.startsWith('3010') || ObjectKey.startsWith('3020') || ObjectKey.startsWith('3030') || ObjectKey.startsWith('3100')){
                        SalesValue -= value;// the value in data source is -ve...
                    }else
                    if(ObjectKey=='5245.010000'){ //Updated by Serena Li on 2019-09-19 for INC0079329: Removed ObjectKey 5282
                        A01+=value;
                    }else if(ObjectKey=='5210.SO1000' || ObjectKey=='5290.FG1000'){
                        A02+=value;
                    }else if(ObjectKey=='5275.000000'){
                        A03+=value;
                    }else if(ObjectKey=='5281.000000'){
                        A04+=value;
                    }else if(ObjectKey=='5245.000000'){
                        A05+=value;
                    }else if(ObjectKey=='5282.010000'){
                        A06+=value;
                    }else if(ObjectKey=='5282.020000' || ObjectKey=='5282.000000'){ //Updated by Serena Li on 2019-09-19 for INC0079329: Added ObjectKey 5282
                        A07+=value;
                    }else if(ObjectKey=='5283.000000'){
                        A08+=value;
                    }else if(ObjectKey=='5282.030000'){
                        A09+=value;
                    }else if(ObjectKey=='5265.020000' || ObjectKey=='5265.010000'){
                        A10+=value;
                    }else if(ObjectKey=='5275.000000'){
                        A11+=value;
                    }else if(ObjectKey=='5275.050000'){
                        A12+=value;
                    }else if(ObjectKey=='5275.010000'){
                        A13+=value;
                    }else if(ObjectKey=='5265.000000' || ObjectKey=='5260.000000' || ObjectKey=='5265.0040000'){
                        A14+=value;
                    }else if(ObjectKey=='5265.030000'){
                        A15+=value;
                    }else if(ObjectKey=='5282.040000'){
                        A17+=value;
                    }else if(ObjectKey=='5582.000000' || ObjectKey=='5582.010000'){
                        B01+=value;
                    }else if(ObjectKey=='5558.000000'){
                        B02+=value;
                    }else if(ObjectKey=='5556.010000' || ObjectKey=='5245.020000'){
                        B03+=value;
                    }else if(ObjectKey=='5551.000000'){
                        B04+=value;
                    }else if(ObjectKey=='5556.000000' || ObjectKey=='5559.020000'){
                        B05+=value;
                    }else if(ObjectKey=='5556.070000' || ObjectKey=='5556.020000'){
                        B06+=value;
                    }else if(ObjectKey=='5559.010000' || ObjectKey=='5559.000000'){
                        B07+=value;
                    }else if(ObjectKey=='5581.000000'){
                        B08+=value;
                    }else if(ObjectKey=='5559.040000'){
                        B09+=value;
                    }else if(ObjectKey=='5651.000000' || ObjectKey=='5651.010000'){
                        B10+=value;
                    }else if(ObjectKey=='5115.000000'){
                        B11+=value;
                    }else if(ObjectKey.startsWith('5111') || ObjectKey.startsWith('5112') || ObjectKey.startsWith('5113') || ObjectKey.startsWith('5114') || ObjectKey.startsWith('5116') || ObjectKey.startsWith('5117') || ObjectKey.startsWith('5118')){
                        B12+=value;
                    }
                    // cost
                    else if(ObjectKey.startsWith('4011') || ObjectKey.startsWith('4019') || ObjectKey.startsWith('5310') || ObjectKey.startsWith('5320') || ObjectKey.startsWith('5330') || ObjectKey.startsWith('9911')){
                        Cost+=value;
                    }else 
                    // move to bottom because it contains all account code start with 52*
                    if(ObjectKey=='5280.000000' || ObjectKey.startsWith('5723') || ObjectKey.startsWith('52')){
                        A16+=value;
                    }else if(ObjectKey.startsWith('5171') || ObjectKey.startsWith('5172') || ObjectKey.startsWith('5173') || ObjectKey.startsWith('5174') || ObjectKey.startsWith('56') || ObjectKey.startsWith('57')){
                        B13+=value;
                    }else if(ObjectKey.startsWith('55')){
                        B14+=value;
                    }

                }
                
            }
            
            
        }
        
        
        public void calculationGroupByType(){
            for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafl : list_pafl){
                string skuId = pafl.ASI_HK_CRM_SKU_Lookup__c;
                string subBrandId = pafl.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c;
                string pafId = pafl.ASI_HK_CRM_Pre_Approval_Form_Lookup__c;
                String key_map = pafId + '_' + subBrandId + '_' + skuId;
                decimal investedAmount = pafl.ASI_HK_CRM_Investment_Value__c;
                string mechanicCode = pafl.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c;
                if(mechanicCode == 'A01'){
                    
                } else if(mechanicCode == 'A02'){
                    A02 += investedAmount;
                    Decimal qty = pafl.ASI_HK_CRM_Investment_Value__c / pafl.ASI_HK_CRM_Price__c;
                    map_sku_skuW.get(key_map).totalBottleWithSTK += qty;
                } else
                if(mechanicCode == 'A03'){
                    A03 += investedAmount;
                } else
                if(mechanicCode == 'A04'){
                    A04 += investedAmount;
                } else
                if(mechanicCode == 'A05'){
                    A05 += investedAmount;
                } else
                if(mechanicCode == 'A06'){
                    A06 += investedAmount;
                } else
                if(mechanicCode == 'A07'){
                    A07 += investedAmount;
                } else
                if(mechanicCode == 'A08'){
                    
                } else
                if(mechanicCode == 'A09'){
                    A09 += investedAmount;
                } else
                if(mechanicCode == 'A10'){
                    A10 += investedAmount;
                } else
                if(mechanicCode == 'A11'){
                    A11 += investedAmount;
                    Decimal qty = pafl.ASI_HK_CRM_Investment_Value__c / pafl.ASI_HK_CRM_Price__c;
                    map_sku_skuW.get(key_map).totalBottleWithSTK += qty;
                } else
                if(mechanicCode == 'A12'){
                    A12 += investedAmount;
                } else
                if(mechanicCode == 'A13'){
                    A13 += investedAmount;
                } else
                if(mechanicCode == 'A14'){
                    A14 += investedAmount;
                } else
                if(mechanicCode == 'A15'){
                    A15 += investedAmount;
                } else
                if(mechanicCode == 'A16'){
                    A16 += investedAmount;
                } else
                if(mechanicCode == 'A17'){
                    A17 += investedAmount;
                    Decimal qty = pafl.ASI_HK_CRM_Investment_Value__c / pafl.ASI_HK_CRM_Price__c;
                    map_sku_skuW.get(key_map).totalBottleWithSTK += qty;
                } else
                if(mechanicCode == 'B01'){
                    B01 += investedAmount;
                } else
                if(mechanicCode == 'B02'){
                    B02 += investedAmount;
                } else
                if(mechanicCode == 'B03'){
                    B03 += investedAmount;
                } else
                if(mechanicCode == 'B04'){
                    B04 += investedAmount;
                } else
                if(mechanicCode == 'B05'){
                    B05 += investedAmount;
                } else
                if(mechanicCode == 'B06'){
                    B06 += investedAmount;
                } else
                if(mechanicCode == 'B07'){
                    B07 += investedAmount;
                } else
                if(mechanicCode == 'B08'){
                    B08 += investedAmount;
                } else
                if(mechanicCode == 'B09'){
                    B09 += investedAmount;
                } else
                if(mechanicCode == 'B10'){
                    B10 += investedAmount;
                } else
                if(mechanicCode == 'B11'){
                    B11 += investedAmount;
                } 
            }
        }
        public void calculationFinalize(Map<String,ASI_CRM_PnL_Cost__c> PnLCostMap, date LastDateOfThisFY){
            this.EndDate = LastDateOfThisFY;
            system.debug('** calculationFinalize **'+ this.EndDate);
            
            for(SKUWrapper w : map_sku_skuW.values()){
                system.debug(w.BrandId+'SubBrandId :  '+w.SubBrandId);
                string PnLCostKey='';
                Date LastDateOfLastFY = this.EndDate.addYears(-1);
                Decimal CostPer9L=0;
                
                // Version 1 cost table extraction logic
                // 1. actual this year
                // 2. actual last year
                // 3. budget this year
                /* 
                if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate)  ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfLastFY) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfLastFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Budget_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Budget_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate) ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate)  ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfLastFY) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfLastFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Budget_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Budget_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate) ).ASI_CRM_Cost_per_9L_YTD__c;
                }
                */
                // Version 2 cost table extraction logic
                // 1. budget this year
                // 2. customer's actual this year
                // 3. customer's actual last year
                /* 
                if(PnLCostMap.containsKey( 'ASI_CRM_HK_Budget_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Budget_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate) ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.customerId + w.SubBrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.customerId + w.SubBrandId + string.valueOf(this.EndDate)  ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.customerId + w.SubBrandId + string.valueOf(LastDateOfLastFY) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.customerId + w.SubBrandId + string.valueOf(LastDateOfLastFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Budget_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Budget_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate) ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Brand' + w.customerId + w.BrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Brand' + w.customerId + w.BrandId + string.valueOf(this.EndDate)  ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Brand' + w.customerId + w.BrandId + string.valueOf(LastDateOfLastFY) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Brand' + w.customerId + w.BrandId + string.valueOf(LastDateOfLastFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                }
                */
                // Version 3 cost table extraction logic
                // 1. budget this year
                // 2. actual this year
                // 3. actual last year
                if(PnLCostMap.containsKey( 'ASI_CRM_HK_Budget_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Budget_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate) ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(this.EndDate)  ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfLastFY) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Sub_Brand' + w.SubBrandId + string.valueOf(LastDateOfLastFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Budget_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Budget_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate) ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(this.EndDate)  ).ASI_CRM_Cost_per_9L_YTD__c;
                }else if(PnLCostMap.containsKey( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfLastFY) )){
                    CostPer9L = PnLCostMap.get( 'ASI_CRM_HK_Actual_Cost_Brand' + w.BrandId + string.valueOf(LastDateOfLastFY) ).ASI_CRM_Cost_per_9L_YTD__c;
                } 
                
                string pafId = w.pafId;
                if(map_paf_includeVolume.containsKey(pafId) && map_paf_includeVolume.get(pafId)){
                    system.debug(w);
                    SalesValue += (w.totalBottleWithSTK * w.price);
                    Volume9L += (w.totalBottleWithSTK * w.bottleSize / 900);
                    Cost += (w.totalBottleWithSTK * w.bottleSize / 900) * CostPer9L;
                }
                if(map_pafId_paflAllProduct.containsKey(pafId)){
                    List<ASI_HK_CRM_Pre_Approval_Form_Item__c> list_pafl = map_pafId_paflAllProduct.get(pafId);
                    for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafl : list_pafl){
                        string mechanicCode = pafl.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c;
                        if(mechanicCode == 'A01'){
                            decimal convertedAmount = 0;
                            if(pafl.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null){
                                convertedAmount += w.totalBottle * pafl.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                            } else
                            if(pafl.ASI_HK_CRM_Rebate_Disc_Percent__c != null){
                                convertedAmount += w.totalBottle * (w.price-w.onInvoiceDisc) * pafl.ASI_HK_CRM_Rebate_Disc_Percent__c / 100;
                            }
                            A01 += convertedAmount;
                        } else
                        if(mechanicCode == 'A08'){
                            decimal convertedAmount = 0;
                            if(pafl.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c != null){
                                convertedAmount += w.totalBottle * pafl.ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c;
                            } else
                            if(pafl.ASI_HK_CRM_Rebate_Disc_Percent__c != null){
                                convertedAmount += w.totalBottle * (w.price-w.onInvoiceDisc) * pafl.ASI_HK_CRM_Rebate_Disc_Percent__c / 100;
                            }
                            A08 += convertedAmount;
                        }
                    }
                }
            }
            
            cost = Math.abs(cost);
            TotalInvestmentBeforeNetSales = A01 + A02 + A03 + A04 + A05 + A06 + A07 + A08 + A09 + A10 + A11 + A12 + A13 + A14 + A15 + A16 + A17 + B01;
            NetSales = SalesValue - TotalInvestmentBeforeNetSales;
            NNPper9L = NetSales / (Volume9L == 0 ? 1 : Volume9L);
            //Cost = CostTemp;
            CM = NetSales - Cost;
            TotalInvestmentAfterNetSales = B02 + B03 + B04 + B05 + B06 + B07 + B08 + B09 + B10 + B11 + B12 + B13 + B14;
            CAAP = CM - TotalInvestmentAfterNetSales;
            TotalInvestment = TotalInvestmentBeforeNetSales + TotalInvestmentAfterNetSales;
            TotalInvestmentPercentOfSalesValues = TotalInvestment / (SalesValue == 0 ? 1 : SalesValue);
            ROIPercent = CAAP / (TotalInvestment == 0 ? 1 : TotalInvestment);
            VariableInvestment = A01 + A02 + A03 + A04 + A05 + A06 + A07 + A08 + A16;
            FixedInvestment = A09 + A10 + A11 + A12 + A13 + A14 + A15 + A17 + B01 + B02 + B03 + B04 + B05 + B06 + B07 + B08 + B09 + B10 + B11 + B12 + B13 + B14;
        }
        public void calculationFinalizeActual(){
            
            TotalInvestmentBeforeNetSales = A01 + A02 + A03 + A04 + A05 + A06 + A07 + A08 + A09 + A10 + A11 + A12 + A13 + A14 + A15 + A16 + A17 + B01;
            NetSales = SalesValue - TotalInvestmentBeforeNetSales;
            NNPper9L = NetSales / (Volume9L == 0 ? 1 : Volume9L);
            //Cost = CostTemp;
            CM = NetSales - Cost;
            TotalInvestmentAfterNetSales = B02 + B03 + B04 + B05 + B06 + B07 + B08 + B09 + B10 + B11 + B12 + B13 + B14;
            CAAP = CM - TotalInvestmentAfterNetSales;
            TotalInvestment = TotalInvestmentBeforeNetSales + TotalInvestmentAfterNetSales;
            TotalInvestmentPercentOfSalesValues = TotalInvestment / (SalesValue == 0 ? 1 : SalesValue);
            ROIPercent = CAAP / (TotalInvestment == 0 ? 1 : TotalInvestment);
            VariableInvestment = A01 + A02 + A03 + A04 + A05 + A06 + A07 + A08 + A16;
            FixedInvestment = A09 + A10 + A11 + A12 + A13 + A14 + A15 + A17 + B01 + B02 + B03 + B04 + B05 + B06 + B07 + B08 + B09 + B10 + B11 + B12 + B13 + B14;
        }
        private void unitInThousandField() {
            SalesValue = SalesValue/1000;
            A01 = A01/1000;
            A02 = A02/1000;
            A03 = A03/1000;
            A04 = A04/1000;
            A05 = A05/1000;
            A06 = A06/1000;
            A07 = A07/1000;
            A08 = A08/1000;
            A09 = A09/1000;
            A10 = A10/1000;
            A11 = A11/1000;
            A12 = A12/1000;
            A13 = A13/1000;
            A14 = A14/1000;
            A15 = A15/1000;
            A16 = A16/1000;
            A17 = A17/1000;
            B01 = B01/1000;
            B02 = B02/1000;
            B03 = B03/1000;
            B04 = B04/1000;
            B05 = B05/1000;
            B06 = B06/1000;
            B07 = B07/1000;
            B08 = B08/1000;
            B09 = B09/1000;
            B10 = B10/1000;
            B11 = B11/1000;
            B12 = B12/1000;
            B13 = B13/1000;
            B14 = B14/1000;
            TotalInvestmentBeforeNetSales = TotalInvestmentBeforeNetSales/1000;
            NetSales = NetSales/1000;
            Cost = Cost/1000;
            CM = CM/1000;
            TotalInvestmentAfterNetSales = TotalInvestmentAfterNetSales/1000;
            CAAP = CAAP/1000;
            TotalInvestment = TotalInvestment/1000;
            VariableInvestment = VariableInvestment/1000;
            FixedInvestment = FixedInvestment/1000;
            TotalInvestmentPercentOfSalesValues = TotalInvestmentPercentOfSalesValues*100;
            ROIPercent = ROIPercent*100;
        }
        private void roundUpField() {
            SalesValue = SalesValue.setScale(1);
            A01 = A01.setScale(1);
            A02 = A02.setScale(1);
            A03 = A03.setScale(1);
            A04 = A04.setScale(1);
            A05 = A05.setScale(1);
            A06 = A06.setScale(1);
            A07 = A07.setScale(1);
            A08 = A08.setScale(1);
            A09 = A09.setScale(1);
            A10 = A10.setScale(1);
            A11 = A11.setScale(1);
            A12 = A12.setScale(1);
            A13 = A13.setScale(1);
            A14 = A14.setScale(1);
            A15 = A15.setScale(1);
            A16 = A16.setScale(1);
            A17 = A17.setScale(1);
            B01 = B01.setScale(1);
            B02 = B02.setScale(1);
            B03 = B03.setScale(1);
            B04 = B04.setScale(1);
            B05 = B05.setScale(1);
            B06 = B06.setScale(1);
            B07 = B07.setScale(1);
            B08 = B08.setScale(1);
            B09 = B09.setScale(1);
            B10 = B10.setScale(1);
            B11 = B11.setScale(1);
            B12 = B12.setScale(1);
            B13 = B13.setScale(1);
            B14 = B14.setScale(1);
            TotalInvestmentBeforeNetSales = TotalInvestmentBeforeNetSales.setScale(1);
            NetSales = NetSales.setScale(1);
            Cost = Cost.setScale(1);
            CM = CM.setScale(1);
            TotalInvestmentAfterNetSales = TotalInvestmentAfterNetSales.setScale(1);
            CAAP = CAAP.setScale(1);
            TotalInvestment = TotalInvestment.setScale(1);
            VariableInvestment = VariableInvestment.setScale(1);
            FixedInvestment = FixedInvestment.setScale(1);
            TotalInvestmentPercentOfSalesValues = TotalInvestmentPercentOfSalesValues.setScale(2);
            ROIPercent = ROIPercent.setScale(2);
            Volume9L = Volume9L.setScale(1);
            NNPper9L = NNPper9L.setScale(2);
        }
        private void roundUpFieldToZero() {
            if(A01 != null) A01 = A01.setScale(0);
            if(A02 != null) A02 = A02.setScale(0);
            if(A03 != null) A03 = A03.setScale(0);
            if(A04 != null) A04 = A04.setScale(0);
            if(A05 != null) A05 = A05.setScale(0);
            if(A06 != null) A06 = A06.setScale(0);
            if(A07 != null) A07 = A07.setScale(0);
            if(A08 != null) A08 = A08.setScale(0);
            if(A09 != null) A09 = A09.setScale(0);
            if(A10 != null) A10 = A10.setScale(0);
            if(A11 != null) A11 = A11.setScale(0);
            if(A12 != null) A12 = A12.setScale(0);
            if(A13 != null) A13 = A13.setScale(0);
            if(A14 != null) A14 = A14.setScale(0);
            if(A15 != null) A15 = A15.setScale(0);
            if(A16 != null) A16 = A16.setScale(0);
            if(A17 != null) A17 = A17.setScale(0);
            if(B01 != null) B01 = B01.setScale(0);
            if(B02 != null) B02 = B02.setScale(0);
            if(B03 != null) B03 = B03.setScale(0);
            if(B04 != null) B04 = B04.setScale(0);
            if(B05 != null) B05 = B05.setScale(0);
            if(B06 != null) B06 = B06.setScale(0);
            if(B07 != null) B07 = B07.setScale(0);
            if(B08 != null) B08 = B08.setScale(0);
            if(B09 != null) B09 = B09.setScale(0);
            if(B10 != null) B10 = B10.setScale(0);
            if(B11 != null) B11 = B11.setScale(0);
            if(B12 != null) B12 = B12.setScale(0);
            if(B13 != null) B13 = B13.setScale(0);
            if(B14 != null) B14 = B14.setScale(0);
            if(SalesValue != null) SalesValue = SalesValue.setScale(0);
            if(TotalInvestmentBeforeNetSales != null) TotalInvestmentBeforeNetSales = TotalInvestmentBeforeNetSales.setScale(0);
            if(NetSales != null) NetSales = NetSales.setScale(0);
            if(Cost != null) Cost = Cost.setScale(0);
            if(CM != null) CM = CM.setScale(0);
            if(TotalInvestmentAfterNetSales != null) TotalInvestmentAfterNetSales = TotalInvestmentAfterNetSales.setScale(0);
            if(CAAP != null) CAAP = CAAP.setScale(0);
            if(TotalInvestment != null) TotalInvestment = TotalInvestment.setScale(0);
            if(TotalInvestmentPercentOfSalesValues != null) TotalInvestmentPercentOfSalesValues = TotalInvestmentPercentOfSalesValues.setScale(0);
            if(ROIPercent != null) ROIPercent = ROIPercent.setScale(0);
            if(VariableInvestment != null) VariableInvestment = VariableInvestment.setScale(0);
            if(FixedInvestment != null) FixedInvestment = FixedInvestment.setScale(0);
            if(Volume9L != null) Volume9L = Volume9L.setScale(0);
            if(NNPper9L != null) NNPper9L = NNPper9L.setScale(0);

        }

    }
    
    //Inner class for storing contract comparison result
    private class ContractComparisonResultWrapper {
        
        private boolean isCompare {get;set;}
        private boolean needCheckDisplay {get;set;}
        private string volumeDisplay {get;set;}
        private string financeDisplay {get;set;}
        private string nnpDisplay {get;set;}
        private integer numberOfMonthToDisplay {get;set;}
        private string startDateToDisplay {get;set;}
        private string endDateToDisplay {get;set;}
        private string customerName {get;set;}
        private string nameOfPAF {get;set;}
        private date LastDateOfThisFY {get;set;}
        private map<string, ASI_CRM_PnL_Cost__c> map_PnLCost {get;set;}
        private ASI_HK_CRM_Pre_Approval_Form__c proposedPAF {get;set;}
        private String sectionName {get;set;}
        private Map<decimal, SectionWrapper> subBrandSectionMap {get;set;}
        private map<string, DetailWrapper> map_type_dW {get;set;}
        private Map<string, boolean> map_paf_includeVolume {get;set;}
        private Map<string, list<ASI_HK_CRM_Pre_Approval_Form_Item__c>> map_pafId_paflAllProduct {get;set;}
        private set<string> MechanicsNotSKU = new set<string>{'A01','A08'};
        
        private Boolean isBaseContract {get; set;}
        
        private ContractComparisonResultWrapper(String sectionName, Boolean isBaseContract, ASI_HK_CRM_Pre_Approval_Form__c proposedPAF, Map<decimal, SectionWrapper> subBrandSectionMap, List<AggregateResult> PnLCostList, map<string, ASI_CRM_PnL_Cost__c> map_PnLCost ){
            this.sectionName = sectionName;
            this.isCompare = false;
            this.needCheckDisplay = true;
            this.proposedPAF = proposedPAF;
            this.isBaseContract = isBaseContract;
            this.subBrandSectionMap = subBrandSectionMap;
            this.map_type_dW = new map<string, DetailWrapper>();
            //this.map_pafId_paflAllProduct = new Map<string, list<ASI_HK_CRM_Pre_Approval_Form_Item__c>>();
            
            //getCost(proposedPAF.ASI_CRM_Ref_Start_Date__c);
            this.map_PnLCost = map_PnLCost;
            setHeader();
            setActualValue(PnLCostList, subBrandSectionMap);
            
            clearAll();
        }
            
        private ContractComparisonResultWrapper(String sectionName, Boolean isBaseContract, ASI_HK_CRM_Pre_Approval_Form__c proposedPAF, list<ASI_HK_CRM_Pre_Approval_Form__c> list_paf, Map<decimal, SectionWrapper> subBrandSectionMap, Map<string, boolean> map_paf_includeVolume, map<string, ASI_CRM_PnL_Cost__c> map_PnLCost) {
            this.sectionName = sectionName;
            this.isCompare = false;
            this.needCheckDisplay = true;
            this.proposedPAF = proposedPAF;
            this.isBaseContract = isBaseContract;
            this.subBrandSectionMap = subBrandSectionMap;
            this.map_paf_includeVolume = map_paf_includeVolume;
            this.map_type_dW = new map<string, DetailWrapper>();
            this.map_pafId_paflAllProduct = new Map<string, list<ASI_HK_CRM_Pre_Approval_Form_Item__c>>();
            
            //getCost(proposedPAF.ASI_HK_CRM_Adjusted_Start_Date__c);
            this.map_PnLCost = map_PnLCost;
            setHeader();
            setValue(list_paf, subBrandSectionMap);
            
            clearAll();
        }
        
        private ContractComparisonResultWrapper(String sectionName, ContractComparisonResultWrapper wrapperToCompare, ContractComparisonResultWrapper wrapperToBeCompared) {
            this.sectionName = sectionName;
            this.isCompare = true;
            this.needCheckDisplay = false;
            this.map_type_dW = new map<string, DetailWrapper>();
            
            setValueCompare(wrapperToCompare, wrapperToBeCompared);
            clearAll();
        }
        
        private ContractComparisonResultWrapper(String sectionName){
            this.sectionName = sectionName;
            this.needCheckDisplay = false;
            clearAll();
        }
        
        private void clearAll(){
            /*
            this.subBrandSectionMap = null;
            this.MechanicsNotSKU = null;
            this.map_paf_includeVolume = null;
            this.map_pafId_paflAllProduct = null;
            this.map_PnLCost = null;
            this.proposedPAF = null;
            */
        }
            
        private void setHeader(){
            this.volumeDisplay = 'Volume';
            this.financeDisplay = 'HKD (\'000)';
            this.nnpDisplay = 'Per 9L Net Selling Price';
            
            Date inputDate = proposedPAF.ASI_HK_CRM_Adjusted_Start_Date__c != null ? proposedPAF.ASI_HK_CRM_Adjusted_Start_Date__c : proposedPAF.ASI_HK_CRM_PAF_Start_Date__c;
            this.LastDateOfThisFY = Date.newinstance(inputDate.year(), 6,30);
            if(inputDate.month() >= 7){
                this.LastDateOfThisFY = LastDateOfThisFY.addYears(1);
            }
            
            ASI_HK_CRM_Pre_Approval_Form__c paf = this.proposedPAF;
            
            this.nameOfPAF = '';
            if(this.sectionName == 'Proposed'){
                this.nameOfPAF = paf.Name;
                this.startDateToDisplay = formatDate(paf.ASI_HK_CRM_Adjusted_Start_Date__c != null ? paf.ASI_HK_CRM_Adjusted_Start_Date__c : paf.ASI_HK_CRM_PAF_Start_Date__c);
                this.endDateToDisplay = formatDate(paf.ASI_HK_CRM_Adjusted_End_Date__c != null ? paf.ASI_HK_CRM_Adjusted_End_Date__c : paf.ASI_HK_CRM_PAF_End_Date__c);
                if(paf.ASI_HK_CRM_Adjusted_Start_Date__c != null && paf.ASI_HK_CRM_Adjusted_End_Date__c != null) this.numberOfMonthToDisplay = paf.ASI_HK_CRM_Adjusted_Start_Date__c.monthsBetween(paf.ASI_HK_CRM_Adjusted_End_Date__c) + 1;
                else 
                if(paf.ASI_HK_CRM_PAF_Start_Date__c != null && paf.ASI_HK_CRM_PAF_End_Date__c != null) this.numberOfMonthToDisplay = paf.ASI_HK_CRM_PAF_Start_Date__c.monthsBetween(paf.ASI_HK_CRM_PAF_End_Date__c) + 1;
                this.customerName = paf.ASI_HK_CRM_PAF_Customer__r.Name;
            }else
            if(this.sectionName == 'Current'){
                date minStartDate;
                date maxEndDate;
                if(paf.ASI_CRM_HK_PAF_no__c != null){
                    this.nameOfPAF += paf.ASI_CRM_HK_PAF_no__r.Name + ', ';
                    date thisStartDate = paf.ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_Adjusted_Start_Date__c != null ? paf.ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_Adjusted_Start_Date__c : paf.ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_PAF_Start_Date__c;
                    date thisEndDate = paf.ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_Adjusted_End_Date__c != null ? paf.ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_Adjusted_End_Date__c : paf.ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_PAF_End_Date__c;
                    if(minStartDate == null || thisStartDate < minStartDate) minStartDate = thisStartDate;
                    if(maxEndDate == null || thisEndDate > maxEndDate) maxEndDate = thisEndDate;
                    this.customerName = paf.ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_PAF_Customer__r.Name;
                }
                if(paf.ASI_CRM_HK_PAF_no_2__c != null){
                    this.nameOfPAF += paf.ASI_CRM_HK_PAF_no_2__r.Name + ', ';
                    date thisStartDate = paf.ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_Adjusted_Start_Date__c != null ? paf.ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_Adjusted_Start_Date__c : paf.ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_PAF_Start_Date__c;
                    date thisEndDate = paf.ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_Adjusted_End_Date__c != null ? paf.ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_Adjusted_End_Date__c : paf.ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_PAF_End_Date__c;
                    if(minStartDate == null || thisStartDate < minStartDate) minStartDate = thisStartDate;
                    if(maxEndDate == null || thisEndDate > maxEndDate) maxEndDate = thisEndDate;
                }
                if(paf.ASI_CRM_HK_PAF_no_3__c != null){
                    this.nameOfPAF += paf.ASI_CRM_HK_PAF_no_3__r.Name + ', ';
                    date thisStartDate = paf.ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_Adjusted_Start_Date__c != null ? paf.ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_Adjusted_Start_Date__c : paf.ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_PAF_Start_Date__c;
                    date thisEndDate = paf.ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_Adjusted_End_Date__c != null ? paf.ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_Adjusted_End_Date__c : paf.ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_PAF_End_Date__c;
                    if(minStartDate == null || thisStartDate < minStartDate) minStartDate = thisStartDate;
                    if(maxEndDate == null || thisEndDate > maxEndDate) maxEndDate = thisEndDate;
                }
                if(paf.ASI_CRM_HK_PAF_no_4__c != null){
                    this.nameOfPAF += paf.ASI_CRM_HK_PAF_no_4__r.Name + ', ';
                    date thisStartDate = paf.ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_Adjusted_Start_Date__c != null ? paf.ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_Adjusted_Start_Date__c : paf.ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_PAF_Start_Date__c;
                    date thisEndDate = paf.ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_Adjusted_End_Date__c != null ? paf.ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_Adjusted_End_Date__c : paf.ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_PAF_End_Date__c;
                    if(minStartDate == null || thisStartDate < minStartDate) minStartDate = thisStartDate;
                    if(maxEndDate == null || thisEndDate > maxEndDate) maxEndDate = thisEndDate;
                }
                if(paf.ASI_CRM_HK_PAF_no_5__c != null){
                    this.nameOfPAF += paf.ASI_CRM_HK_PAF_no_5__r.Name + ', ';
                    date thisStartDate = paf.ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_Adjusted_Start_Date__c != null ? paf.ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_Adjusted_Start_Date__c : paf.ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_PAF_Start_Date__c;
                    date thisEndDate = paf.ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_Adjusted_End_Date__c != null ? paf.ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_Adjusted_End_Date__c : paf.ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_PAF_End_Date__c;
                    if(minStartDate == null || thisStartDate < minStartDate) minStartDate = thisStartDate;
                    if(maxEndDate == null || thisEndDate > maxEndDate) maxEndDate = thisEndDate;
                }
                this.nameOfPAF = this.nameOfPAF.subString(0,this.nameOfPAF.length()-2);
                
                this.startDateToDisplay = formatDate(minStartDate);
                this.endDateToDisplay = formatDate(maxEndDate);
                if(minStartDate!=null && maxEndDate!=null) this.numberOfMonthToDisplay = minStartDate.monthsBetween(maxEndDate) + 1;
            }else
            if(this.sectionName == 'Actual'){
                this.startDateToDisplay = formatDate(paf.ASI_CRM_Ref_Start_Date__c != null ? paf.ASI_CRM_Ref_Start_Date__c : paf.ASI_HK_CRM_PAF_Start_Date__c);
                this.endDateToDisplay = formatDate(paf.ASI_CRM_Ref_End_Date__c != null ? paf.ASI_CRM_Ref_End_Date__c : paf.ASI_HK_CRM_PAF_End_Date__c);
                if(paf.ASI_CRM_Ref_Start_Date__c != null && paf.ASI_CRM_Ref_End_Date__c != null) this.numberOfMonthToDisplay = paf.ASI_CRM_Ref_Start_Date__c.monthsBetween(paf.ASI_CRM_Ref_End_Date__c) + 1;
                else 
                if(paf.ASI_HK_CRM_PAF_Start_Date__c != null && paf.ASI_HK_CRM_PAF_End_Date__c != null) this.numberOfMonthToDisplay = paf.ASI_HK_CRM_PAF_Start_Date__c.monthsBetween(paf.ASI_HK_CRM_PAF_End_Date__c) + 1;
                this.customerName = paf.ASI_HK_CRM_PAF_Customer__r.Name;
                if(paf.ASI_HK_CRM_PAF_Customer2__c!=null) this.customerName += ', ' + paf.ASI_HK_CRM_PAF_Customer2__r.Name;
                if(paf.ASI_HK_CRM_PAF_Customer3__c!=null) this.customerName += ', ' + paf.ASI_HK_CRM_PAF_Customer3__r.Name;
                if(paf.ASI_HK_CRM_PAF_Customer4__c!=null) this.customerName += ', ' + paf.ASI_HK_CRM_PAF_Customer4__r.Name;
            }else{
                this.startDateToDisplay = '';
                this.endDateToDisplay = '';
            }
        }
        
        private void setValueCompare(ContractComparisonResultWrapper wrapperToCompare, ContractComparisonResultWrapper wrapperToBeCompared){            
            for(string key : wrapperToCompare.map_type_dW.keySet()){
                DetailWrapper w = new DetailWrapper(key);
                DetailWrapper wToCompare = wrapperToCompare.map_type_dW.get(key);
                DetailWrapper wToBeCompared = wrapperToBeCompared.map_type_dW.get(key);
                
                w.A01 = wToBeCompared.A01 != 0 ? ((wToCompare.A01 / wToBeCompared.A01) - 1) * 100 : null;
                w.A02 = wToBeCompared.A02 != 0 ? ((wToCompare.A02 / wToBeCompared.A02) - 1) * 100 : null;
                w.A03 = wToBeCompared.A03 != 0 ? ((wToCompare.A03 / wToBeCompared.A03) - 1) * 100 : null;
                w.A04 = wToBeCompared.A04 != 0 ? ((wToCompare.A04 / wToBeCompared.A04) - 1) * 100 : null;
                w.A05 = wToBeCompared.A05 != 0 ? ((wToCompare.A05 / wToBeCompared.A05) - 1) * 100 : null;
                w.A06 = wToBeCompared.A06 != 0 ? ((wToCompare.A06 / wToBeCompared.A06) - 1) * 100 : null;
                w.A07 = wToBeCompared.A07 != 0 ? ((wToCompare.A07 / wToBeCompared.A07) - 1) * 100 : null;
                w.A08 = wToBeCompared.A08 != 0 ? ((wToCompare.A08 / wToBeCompared.A08) - 1) * 100 : null;
                w.A09 = wToBeCompared.A09 != 0 ? ((wToCompare.A09 / wToBeCompared.A09) - 1) * 100 : null;
                w.A10 = wToBeCompared.A10 != 0 ? ((wToCompare.A10 / wToBeCompared.A10) - 1) * 100 : null;
                w.A11 = wToBeCompared.A11 != 0 ? ((wToCompare.A11 / wToBeCompared.A11) - 1) * 100 : null;
                w.A12 = wToBeCompared.A12 != 0 ? ((wToCompare.A12 / wToBeCompared.A12) - 1) * 100 : null;
                w.A13 = wToBeCompared.A13 != 0 ? ((wToCompare.A13 / wToBeCompared.A13) - 1) * 100 : null;
                w.A14 = wToBeCompared.A14 != 0 ? ((wToCompare.A14 / wToBeCompared.A14) - 1) * 100 : null;
                w.A15 = wToBeCompared.A15 != 0 ? ((wToCompare.A15 / wToBeCompared.A15) - 1) * 100 : null;
                w.A16 = wToBeCompared.A16 != 0 ? ((wToCompare.A16 / wToBeCompared.A16) - 1) * 100 : null;
                w.A17 = wToBeCompared.A17 != 0 ? ((wToCompare.A17 / wToBeCompared.A17) - 1) * 100 : null;
                w.B01 = wToBeCompared.B01 != 0 ? ((wToCompare.B01 / wToBeCompared.B01) - 1) * 100 : null;
                w.B02 = wToBeCompared.B02 != 0 ? ((wToCompare.B02 / wToBeCompared.B02) - 1) * 100 : null;
                w.B03 = wToBeCompared.B03 != 0 ? ((wToCompare.B03 / wToBeCompared.B03) - 1) * 100 : null;
                w.B04 = wToBeCompared.B04 != 0 ? ((wToCompare.B04 / wToBeCompared.B04) - 1) * 100 : null;
                w.B05 = wToBeCompared.B05 != 0 ? ((wToCompare.B05 / wToBeCompared.B05) - 1) * 100 : null;
                w.B06 = wToBeCompared.B06 != 0 ? ((wToCompare.B06 / wToBeCompared.B06) - 1) * 100 : null;
                w.B07 = wToBeCompared.B07 != 0 ? ((wToCompare.B07 / wToBeCompared.B07) - 1) * 100 : null;
                w.B08 = wToBeCompared.B08 != 0 ? ((wToCompare.B08 / wToBeCompared.B08) - 1) * 100 : null;
                w.B09 = wToBeCompared.B09 != 0 ? ((wToCompare.B09 / wToBeCompared.B09) - 1) * 100 : null;
                w.B10 = wToBeCompared.B10 != 0 ? ((wToCompare.B10 / wToBeCompared.B10) - 1) * 100 : null;
                w.B11 = wToBeCompared.B11 != 0 ? ((wToCompare.B11 / wToBeCompared.B11) - 1) * 100 : null;
                w.B12 = wToBeCompared.B12 != 0 ? ((wToCompare.B12 / wToBeCompared.B12) - 1) * 100 : null;
                w.B13 = wToBeCompared.B13 != 0 ? ((wToCompare.B13 / wToBeCompared.B13) - 1) * 100 : null;
                w.B14 = wToBeCompared.B14 != 0 ? ((wToCompare.B14 / wToBeCompared.B14) - 1) * 100 : null;
                w.SalesValue = wToBeCompared.SalesValue != 0 ? ((wToCompare.SalesValue / wToBeCompared.SalesValue) - 1) * 100 : null;
                w.TotalInvestmentBeforeNetSales = wToBeCompared.TotalInvestmentBeforeNetSales != 0 ? ((wToCompare.TotalInvestmentBeforeNetSales / wToBeCompared.TotalInvestmentBeforeNetSales) - 1) * 100 : null;
                w.NetSales = wToBeCompared.NetSales != 0 ? ((wToCompare.NetSales / wToBeCompared.NetSales) - 1) * 100 : null;
                w.Cost = wToBeCompared.Cost != 0 ? ((wToCompare.Cost / wToBeCompared.Cost) - 1) * 100 : null;
                w.CM = wToBeCompared.CM != 0 ? ((wToCompare.CM / wToBeCompared.CM) - 1) * 100 : null;
                w.TotalInvestmentAfterNetSales = wToBeCompared.TotalInvestmentAfterNetSales != 0 ? ((wToCompare.TotalInvestmentAfterNetSales / wToBeCompared.TotalInvestmentAfterNetSales) - 1) * 100 : null;
                w.CAAP = wToBeCompared.CAAP != 0 ? ((wToCompare.CAAP / wToBeCompared.CAAP) - 1) * 100 : null;
                w.TotalInvestment = wToBeCompared.TotalInvestment != 0 ? ((wToCompare.TotalInvestment / wToBeCompared.TotalInvestment) - 1) * 100 : null;
                w.VariableInvestment = wToBeCompared.VariableInvestment != 0 ? ((wToCompare.VariableInvestment / wToBeCompared.VariableInvestment) - 1) * 100 : null;
                w.FixedInvestment = wToBeCompared.FixedInvestment != 0 ? ((wToCompare.FixedInvestment / wToBeCompared.FixedInvestment) - 1) * 100 : null;
                w.Volume9L = wToBeCompared.Volume9L != 0 ? ((wToCompare.Volume9L / wToBeCompared.Volume9L) - 1) * 100 : null;
                w.NNPper9L = wToBeCompared.NNPper9L != 0 ? ((wToCompare.NNPper9L / wToBeCompared.NNPper9L) - 1) * 100 : null;
                w.TotalInvestmentPercentOfSalesValues = wToCompare.TotalInvestmentPercentOfSalesValues - wToBeCompared.TotalInvestmentPercentOfSalesValues;
                w.ROIPercent = wToCompare.ROIPercent - wToBeCompared.ROIPercent;

                /*
                w.A01 = (wToCompare.A01 - wToBeCompared.A01) * 100 / (wToBeCompared.A01 != 0 ? wToBeCompared.A01 : 1);
                w.A02 = (wToCompare.A02 - wToBeCompared.A02) * 100 / (wToBeCompared.A02 != 0 ? wToBeCompared.A02 : 1);
                w.A03 = (wToCompare.A03 - wToBeCompared.A03) * 100 / (wToBeCompared.A03 != 0 ? wToBeCompared.A03 : 1);
                w.A04 = (wToCompare.A04 - wToBeCompared.A04) * 100 / (wToBeCompared.A04 != 0 ? wToBeCompared.A04 : 1);
                w.A05 = (wToCompare.A05 - wToBeCompared.A05) * 100 / (wToBeCompared.A05 != 0 ? wToBeCompared.A05 : 1);
                w.A06 = (wToCompare.A06 - wToBeCompared.A06) * 100 / (wToBeCompared.A06 != 0 ? wToBeCompared.A06 : 1);
                w.A07 = (wToCompare.A07 - wToBeCompared.A07) * 100 / (wToBeCompared.A07 != 0 ? wToBeCompared.A07 : 1);
                w.A08 = (wToCompare.A08 - wToBeCompared.A08) * 100 / (wToBeCompared.A08 != 0 ? wToBeCompared.A08 : 1);
                w.A09 = (wToCompare.A09 - wToBeCompared.A09) * 100 / (wToBeCompared.A09 != 0 ? wToBeCompared.A09 : 1);
                w.A10 = (wToCompare.A10 - wToBeCompared.A10) * 100 / (wToBeCompared.A10 != 0 ? wToBeCompared.A10 : 1);
                w.A11 = (wToCompare.A11 - wToBeCompared.A11) * 100 / (wToBeCompared.A11 != 0 ? wToBeCompared.A11 : 1);
                w.A12 = (wToCompare.A12 - wToBeCompared.A12) * 100 / (wToBeCompared.A12 != 0 ? wToBeCompared.A12 : 1);
                w.A13 = (wToCompare.A13 - wToBeCompared.A13) * 100 / (wToBeCompared.A13 != 0 ? wToBeCompared.A13 : 1);
                w.A14 = (wToCompare.A14 - wToBeCompared.A14) * 100 / (wToBeCompared.A14 != 0 ? wToBeCompared.A14 : 1);
                w.A15 = (wToCompare.A15 - wToBeCompared.A15) * 100 / (wToBeCompared.A15 != 0 ? wToBeCompared.A15 : 1);
                w.A16 = (wToCompare.A16 - wToBeCompared.A16) * 100 / (wToBeCompared.A16 != 0 ? wToBeCompared.A16 : 1);
                w.A17 = (wToCompare.A17 - wToBeCompared.A17) * 100 / (wToBeCompared.A17 != 0 ? wToBeCompared.A17 : 1);
                w.B01 = (wToCompare.B01 - wToBeCompared.B01) * 100 / (wToBeCompared.B01 != 0 ? wToBeCompared.B01 : 1);
                w.B02 = (wToCompare.B02 - wToBeCompared.B02) * 100 / (wToBeCompared.B02 != 0 ? wToBeCompared.B02 : 1);
                w.B03 = (wToCompare.B03 - wToBeCompared.B03) * 100 / (wToBeCompared.B03 != 0 ? wToBeCompared.B03 : 1);
                w.B04 = (wToCompare.B04 - wToBeCompared.B04) * 100 / (wToBeCompared.B04 != 0 ? wToBeCompared.B04 : 1);
                w.B05 = (wToCompare.B05 - wToBeCompared.B05) * 100 / (wToBeCompared.B05 != 0 ? wToBeCompared.B05 : 1);
                w.B06 = (wToCompare.B06 - wToBeCompared.B06) * 100 / (wToBeCompared.B06 != 0 ? wToBeCompared.B06 : 1);
                w.B07 = (wToCompare.B07 - wToBeCompared.B07) * 100 / (wToBeCompared.B07 != 0 ? wToBeCompared.B07 : 1);
                w.B08 = (wToCompare.B08 - wToBeCompared.B08) * 100 / (wToBeCompared.B08 != 0 ? wToBeCompared.B08 : 1);
                w.B09 = (wToCompare.B09 - wToBeCompared.B09) * 100 / (wToBeCompared.B09 != 0 ? wToBeCompared.B09 : 1);
                w.B10 = (wToCompare.B10 - wToBeCompared.B10) * 100 / (wToBeCompared.B10 != 0 ? wToBeCompared.B10 : 1);
                w.B11 = (wToCompare.B11 - wToBeCompared.B11) * 100 / (wToBeCompared.B11 != 0 ? wToBeCompared.B11 : 1);
                w.B12 = (wToCompare.B12 - wToBeCompared.B12) * 100 / (wToBeCompared.B12 != 0 ? wToBeCompared.B12 : 1);
                w.B13 = (wToCompare.B13 - wToBeCompared.B13) * 100 / (wToBeCompared.B13 != 0 ? wToBeCompared.B13 : 1);
                w.B14 = (wToCompare.B14 - wToBeCompared.B14) * 100 / (wToBeCompared.B14 != 0 ? wToBeCompared.B14 : 1);
                w.SalesValue = (wToCompare.SalesValue - wToBeCompared.SalesValue) * 100 / (wToBeCompared.SalesValue != 0 ? wToBeCompared.SalesValue : 1);
                w.TotalInvestmentBeforeNetSales = (wToCompare.TotalInvestmentBeforeNetSales - wToBeCompared.TotalInvestmentBeforeNetSales) * 100 / (wToBeCompared.TotalInvestmentBeforeNetSales != 0 ? wToBeCompared.TotalInvestmentBeforeNetSales : 1);
                w.NetSales = (wToCompare.NetSales - wToBeCompared.NetSales) * 100 / (wToBeCompared.NetSales != 0 ? wToBeCompared.NetSales : 1);
                w.Cost = (wToCompare.Cost - wToBeCompared.Cost) * 100 / (wToBeCompared.Cost != 0 ? wToBeCompared.Cost : 1);
                w.CM = (wToCompare.CM - wToBeCompared.CM) * 100 / (wToBeCompared.CM != 0 ? wToBeCompared.CM : 1);
                w.TotalInvestmentAfterNetSales = (wToCompare.TotalInvestmentAfterNetSales - wToBeCompared.TotalInvestmentAfterNetSales) * 100 / (wToBeCompared.TotalInvestmentAfterNetSales != 0 ? wToBeCompared.TotalInvestmentAfterNetSales : 1);
                w.CAAP = (wToCompare.CAAP - wToBeCompared.CAAP) * 100 / (wToBeCompared.CAAP != 0 ? wToBeCompared.CAAP : 1);
                w.TotalInvestment = (wToCompare.TotalInvestment - wToBeCompared.TotalInvestment) * 100 / (wToBeCompared.TotalInvestment != 0 ? wToBeCompared.TotalInvestment : 1);
                w.TotalInvestmentPercentOfSalesValues = wToCompare.TotalInvestmentPercentOfSalesValues - wToBeCompared.TotalInvestmentPercentOfSalesValues;
                w.ROIPercent = wToCompare.ROIPercent - wToBeCompared.ROIPercent;
                w.VariableInvestment = (wToCompare.VariableInvestment - wToBeCompared.VariableInvestment) * 100 / (wToBeCompared.VariableInvestment != 0 ? wToBeCompared.VariableInvestment : 1);
                w.FixedInvestment = (wToCompare.FixedInvestment - wToBeCompared.FixedInvestment) * 100 / (wToBeCompared.FixedInvestment != 0 ? wToBeCompared.FixedInvestment : 1);
                w.Volume9L = (wToCompare.Volume9L - wToBeCompared.Volume9L) * 100 / (wToBeCompared.Volume9L != 0 ? wToBeCompared.Volume9L : 1);
                w.NNPper9L = (wToCompare.NNPper9L - wToBeCompared.NNPper9L) * 100 / (wToBeCompared.NNPper9L != 0 ? wToBeCompared.NNPper9L : 1);
                */

                this.map_type_dW.put(key, w);
            }
            
            for(DetailWrapper dw : this.map_type_dW.values()){
                dw.roundUpFieldToZero();
            }
        }
        
        private void setActualValue(list<AggregateResult> PnLCostList, Map<decimal, SectionWrapper> subBrandSectionMap){
            system.debug('hi');
            map<string, string> map_subBrandName = new map<string, string>();
            for(SectionWrapper w : subBrandSectionMap.values()){
                for(string brandId : w.set_recordId){
                    map_subBrandName.put(brandId, w.displayName);
                }
                DetailWrapper dwB = new DetailWrapper(w.displayName, map_paf_includeVolume);
                map_type_dW.put(w.displayName, dwB);
                DetailWrapper dwBOthers = new DetailWrapper(w.displayName+'_others', map_paf_includeVolume);
                map_type_dW.put(w.displayName+'_others', dwBOthers);
                if(w.hasSubSection){
                    for(SectionWrapper sw : w.subSectionMap.values()){
                        for(string subBrandId : sw.set_recordId){
                            map_subBrandName.put(subBrandId, sw.displayName);
                        }
                        DetailWrapper dwSB = new DetailWrapper(sw.displayName, map_paf_includeVolume);
                        map_type_dW.put(sw.displayName, dwSB);
                    }
                }
            }
            DetailWrapper dwOthers = new DetailWrapper('Others', map_paf_includeVolume);
            map_type_dW.put('Others', dwOthers);
            DetailWrapper dwTotal = new DetailWrapper('total', map_paf_includeVolume);
            map_type_dW.put('total', dwTotal);
            
            for(AggregateResult PnlCost : PnLCostList){
                string brandId = String.valueOf(PnlCost.get('brandId'));
                string subBrandId = String.valueOf(PnlCost.get('subBrandId'));
                
                string brandName = map_subBrandName.containsKey(brandId) ? map_subBrandName.get(brandId) : '';
                string subBrandName = map_subBrandName.containsKey(subBrandId) ? map_subBrandName.get(subBrandId) : '';
                /*
                for(SectionWrapper w : subBrandSectionMap.values()){
                    if(w.set_recordId.contains(brandId)){
                        brandName = w.displayName;
                    }
                    if(w.hasSubSection){
                        for(SectionWrapper sw : w.subSectionMap.values()){
                            if(sw.set_recordId.contains(subBrandId)){
                                subBrandName = sw.displayName;
                            }
                        }
                    }
                }
                */
                
                if(brandName != ''){
                    DetailWrapper dw = map_type_dW.containsKey(brandName) ? map_type_dW.get(brandName) : new DetailWrapper(brandName);
                    dw.addPnLCostLine(PnlCost);
                    map_type_dW.put(brandName, dw);
                }
                if(subBrandName != ''){
                    DetailWrapper dw = map_type_dW.containsKey(subBrandName) ? map_type_dW.get(subBrandName) : new DetailWrapper(subBrandName);
                    dw.addPnLCostLine(PnlCost);
                    map_type_dW.put(subBrandName, dw);
                }
                if(brandName != '' && subBrandName == ''){
                    string keyOthers = brandName + '_others';
                    DetailWrapper dw = map_type_dW.containsKey(keyOthers) ? map_type_dW.get(keyOthers) : new DetailWrapper(keyOthers);
                    dw.addPnLCostLine(PnlCost);
                    map_type_dW.put(keyOthers, dw);
                }
                if(brandName == '' && subBrandName == ''){
                    string keyOthers = 'Others';
                    DetailWrapper dw = map_type_dW.containsKey(keyOthers) ? map_type_dW.get(keyOthers) : new DetailWrapper(keyOthers);
                    dw.addPnLCostLine(PnlCost);
                    map_type_dW.put(keyOthers, dw);
                }
                
                string keyTotal = 'total';
                DetailWrapper dw = map_type_dW.containsKey(keyTotal) ? map_type_dW.get(keyTotal) : new DetailWrapper(keyTotal);
                dw.addPnLCostLine(PnlCost);
                map_type_dW.put(keyTotal, dw);
                
            }
            system.debug('hi2');
            
            for(DetailWrapper dw : map_type_dW.values()){
            system.debug('hi3');
                dw.getSalesTargetActual();
                dw.calculationGroupByTypeActual(this.map_PnLCost, this.LastDateOfThisFY);
                dw.calculationFinalizeActual();
                dw.unitInThousandField();
                dw.roundUpField();
                dw.clearAll();
            system.debug('hi4');
            }
            
            
        }
        
        
        
        
        
        
        private void setValue(list<ASI_HK_CRM_Pre_Approval_Form__c> list_paf, Map<decimal, SectionWrapper> subBrandSectionMap) {
            map<string, string> map_subBrandName = new map<string, string>();
            for(SectionWrapper w : subBrandSectionMap.values()){
                for(string brandId : w.set_recordId){
                    map_subBrandName.put(brandId, w.displayName);
                }
                DetailWrapper dwB = new DetailWrapper(w.displayName, map_paf_includeVolume);
                map_type_dW.put(w.displayName, dwB);
                DetailWrapper dwBOthers = new DetailWrapper(w.displayName+'_others', map_paf_includeVolume);
                map_type_dW.put(w.displayName+'_others', dwBOthers);
                if(w.hasSubSection){
                    for(SectionWrapper sw : w.subSectionMap.values()){
                        for(string subBrandId : sw.set_recordId){
                            map_subBrandName.put(subBrandId, sw.displayName);
                        }
                        DetailWrapper dwSB = new DetailWrapper(sw.displayName, map_paf_includeVolume);
                        map_type_dW.put(sw.displayName, dwSB);
                    }
                }
            }
            DetailWrapper dwOthers = new DetailWrapper('Others', map_paf_includeVolume);
            map_type_dW.put('Others', dwOthers);
            DetailWrapper dwTotal = new DetailWrapper('total', map_paf_includeVolume);
            map_type_dW.put('total', dwTotal);
            
            for(ASI_HK_CRM_Pre_Approval_Form__c paf : list_paf){
                
                //ASI_HK_CRM_Adjusted_Start_Date__c
                for(ASI_HK_CRM_Pre_Approval_Form_Item__c pafl : paf.Pre_Approval_Form_Items_Link_To_PAF_Form__r){
                    string mechanicCode = pafl.ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c;
                    /*
                    if(pafl.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c!=null){
                        SubBrandIdSet.add(pafl.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c);
                    }
                    */
                    if(!MechanicsNotSKU.contains(mechanicCode)){
                        string brandId = pafl.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c;
                        string subBrandId = pafl.ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c;
                        
                        string brandName = map_subBrandName.containsKey(brandId) ? map_subBrandName.get(brandId) : '';
                        string subBrandName = map_subBrandName.containsKey(subBrandId) ? map_subBrandName.get(subBrandId) : '';
                        
                        if(brandName != ''){
                            DetailWrapper dw = map_type_dW.containsKey(brandName) ? map_type_dW.get(brandName) : new DetailWrapper(brandName, map_paf_includeVolume);
                            dw.addLine(pafl);
                            map_type_dW.put(brandName, dw);
                        }
                        if(subBrandName != ''){
                            DetailWrapper dw = map_type_dW.containsKey(subBrandName) ? map_type_dW.get(subBrandName) : new DetailWrapper(subBrandName, map_paf_includeVolume);
                            dw.addLine(pafl);
                            map_type_dW.put(subBrandName, dw);
                        }
                        if(brandName != '' && subBrandName == ''){
                            string keyOthers = brandName + '_others';
                            DetailWrapper dw = map_type_dW.containsKey(keyOthers) ? map_type_dW.get(keyOthers) : new DetailWrapper(keyOthers, map_paf_includeVolume);
                            dw.addLine(pafl);
                            map_type_dW.put(keyOthers, dw);
                        }
                        if(brandName == '' && subBrandName == ''){
                            string keyOthers = 'Others';
                            DetailWrapper dw = map_type_dW.containsKey(keyOthers) ? map_type_dW.get(keyOthers) : new DetailWrapper(keyOthers, map_paf_includeVolume);
                            dw.addLine(pafl);
                            map_type_dW.put(keyOthers, dw);
                        }
                        string keyTotal = 'total';
                        DetailWrapper dw = map_type_dW.containsKey(keyTotal) ? map_type_dW.get(keyTotal) : new DetailWrapper(keyTotal, map_paf_includeVolume);
                        dw.addLine(pafl);
                        map_type_dW.put(keyTotal, dw);
                    } else {
                        string pafId = pafl.ASI_HK_CRM_Pre_Approval_Form_Lookup__c;
                        list<ASI_HK_CRM_Pre_Approval_Form_Item__c> list_pafl = map_pafId_paflAllProduct.containsKey(pafId) ? map_pafId_paflAllProduct.get(pafId) : new list<ASI_HK_CRM_Pre_Approval_Form_Item__c>();
                        list_pafl.add(pafl);
                        map_pafId_paflAllProduct.put(pafId, list_pafl);
                    }
                }
            }
            
            
            for(DetailWrapper dw : map_type_dW.values()){
                dw.addAllProductLine(map_pafId_paflAllProduct);
                dw.getSalesTarget();
                dw.calculationGroupByType();
                dw.calculationFinalize(this.map_PnLCost, this.LastDateOfThisFY);
                dw.unitInThousandField();
                dw.roundUpField();
                //system.debug(dw);
                dw.clearAll();
            }
            

        }
        

    }

    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP = Schema.SObjectType.ASI_HK_CRM_Pre_Approval_Form__c.fields.getMap();
    
    private final static list<string> CONTRACT_FIELD_LIST_SIMPLE = new list<string>{
        'Name',
        'ASI_HK_CRM_Adjusted_Start_Date__c',
        'ASI_HK_CRM_Adjusted_End_Date__c',
        'ASI_CRM_Ref_Start_Date__c',
        'ASI_CRM_Ref_End_Date__c',
        'ASI_HK_CRM_PAF_Start_Date__c',
        'ASI_HK_CRM_PAF_End_Date__c',
        'ASI_HK_CRM_PAF_No_of_Months__c',
        'ASI_CRM_Short_Term_Promotion__c',
        'ASI_CRM_HK_PAF_no__c',
        'ASI_CRM_HK_PAF_no_2__c',
        'ASI_CRM_HK_PAF_no_3__c',
        'ASI_CRM_HK_PAF_no_4__c',
        'ASI_CRM_HK_PAF_no_5__c',
        'ASI_CRM_HK_PAF_no__r.Name',
        'ASI_CRM_HK_PAF_no_2__r.Name',
        'ASI_CRM_HK_PAF_no_3__r.Name',
        'ASI_CRM_HK_PAF_no_4__r.Name',
        'ASI_CRM_HK_PAF_no_5__r.Name',
        'ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_Adjusted_Start_Date__c',
        'ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_Adjusted_Start_Date__c',
        'ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_Adjusted_Start_Date__c',
        'ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_Adjusted_Start_Date__c',
        'ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_Adjusted_Start_Date__c',
        'ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_Adjusted_End_Date__c',
        'ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_Adjusted_End_Date__c',
        'ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_Adjusted_End_Date__c',
        'ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_Adjusted_End_Date__c',
        'ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_Adjusted_End_Date__c',
        'ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_PAF_Start_Date__c',
        'ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_PAF_Start_Date__c',
        'ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_PAF_Start_Date__c',
        'ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_PAF_Start_Date__c',
        'ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_PAF_Start_Date__c',
        'ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_PAF_End_Date__c',
        'ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_PAF_End_Date__c',
        'ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_PAF_End_Date__c',
        'ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_PAF_End_Date__c',
        'ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_PAF_End_Date__c',
        'ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_PAF_Customer__r.Name',
        'ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_PAF_Customer__r.Name',
        'ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_PAF_Customer__r.Name',
        'ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_PAF_Customer__r.Name',
        'ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_PAF_Customer__r.Name',
        'ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_PAF_Customer__c',
        'ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_PAF_Customer__c',
        'ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_PAF_Customer__c',
        'ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_PAF_Customer__c',
        'ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_PAF_Customer__c',
        'ASI_CRM_HK_Pl_volume1__c',
        'ASI_CRM_HK_Pl_volume2__c',
        'ASI_CRM_HK_Pl_volume3__c',
        'ASI_CRM_HK_Pl_volume4__c',
        'ASI_CRM_HK_Pl_volume5__c',
        'ASI_HK_CRM_PAF_Customer__c',
        'ASI_HK_CRM_PAF_Customer2__c',
        'ASI_HK_CRM_PAF_Customer3__c',
        'ASI_HK_CRM_PAF_Customer4__c',
        'ASI_HK_CRM_PAF_Customer__r.Name',
        'ASI_HK_CRM_PAF_Customer2__r.Name',
        'ASI_HK_CRM_PAF_Customer3__r.Name',
        'ASI_HK_CRM_PAF_Customer4__r.Name'
    };
                
    private final static List<String> MECHANICS_FIELD_LIST = new List<string>{
        'Id'
        , 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__c' 
        , 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__c' 
        , 'ASI_HK_CRM_SKU_Lookup__c'
        //, 'ASI_HK_CRM_SKU_Lookup__r.ASI_FOC_Packing_Description__c'
        //, 'ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_SKU_Code__c'
        , 'ASI_HK_CRM_SKU_Lookup__r.ASI_HK_CRM_Std_Bottle_Size__c'
        //, 'ASI_CRM_HK_Pricing_Item__c' 
        //, 'ASI_CRM_HK_Free_SKU__r.Name' 
        , 'ASI_HK_CRM_Target_Volume_Qty__c'
        , 'ASI_HK_CRM_Price__c'
        , 'ASI_HK_CRM_Investment_Value__c '
        , 'ASI_HK_CRM_Rebate_Disc_Percent__c'
        , 'ASI_HK_CRM_Rebate_Disc_Amt_Per_BT__c'
        //, 'ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Mechanic_Type__c'
        , 'ASI_HK_CRM_Mechanic__r.ASI_HK_CRM_Code__c'
        , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__c'
        , 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_PAF_Customer__c'
        //, 'ASI_HK_CRM_Pre_Approval_Form_Lookup__r.ASI_HK_CRM_Adjusted_End_Date__c'
    };
     
    /*
    private static final List<String> LIST_RTID_BUDGETCOST = new List<string>{
        Global_RecordTypeCache.getRTId('ASI_CRM_PnL_Cost__cASI_CRM_HK_Budget_Cost_Brand'),
        Global_RecordTypeCache.getRTId('ASI_CRM_PnL_Cost__cASI_CRM_HK_Budget_Cost_Sub_Brand')
    };
        
    private static final List<String> LIST_RTID_ACTUALCOST = new List<string>{
        Global_RecordTypeCache.getRTId('ASI_CRM_PnL_Cost__cASI_CRM_HK_Actual_Cost_Brand'),
        Global_RecordTypeCache.getRTId('ASI_CRM_PnL_Cost__cASI_CRM_HK_Actual_Cost_Sub_Brand')
    };
    */
        
    private static final List<String> LIST_RTID_BUDGETACTUALCOST = new List<string>{
        Global_RecordTypeCache.getRTId('ASI_CRM_PnL_Cost__cASI_CRM_HK_Budget_Cost_Brand'),
        Global_RecordTypeCache.getRTId('ASI_CRM_PnL_Cost__cASI_CRM_HK_Budget_Cost_Sub_Brand'),
        Global_RecordTypeCache.getRTId('ASI_CRM_PnL_Cost__cASI_CRM_HK_Actual_Cost_Brand'),
        Global_RecordTypeCache.getRTId('ASI_CRM_PnL_Cost__cASI_CRM_HK_Actual_Cost_Sub_Brand')
    };
        
    private String baseContractId;
    private List<String> contractIdList = new List<String>();
    private Set<String> currentPAFIdList = new Set<String>();
    
    //JSON String for VF Page
    public String contractListJson                        {get {return toJsonString(contractList);}}
    public String contractComparisonResultWrapperListJson {get {return toJsonString(contractComparisonResultWrapperList);}}
    public String subBrandSectionMapJson                  {get {return toJsonString(subBrandSectionMap);}}
    public String map_type_isDisplayRow_Json              {get {return toJsonString(map_type_isDisplayRow);}}
    public Boolean getShowComparison(){
        return Boolean.valueOf(ApexPages.currentPage().getParameters().containsKey('showComparison') ? ApexPages.currentPage().getParameters().get('showComparison') : 'false');
    }

    //All contract records
    public List<ASI_HK_CRM_Pre_Approval_Form__c> contractList { get; set; }
    public transient List<ContractComparisonResultWrapper> contractComparisonResultWrapperList;
    public Map<string, boolean> map_paf_includeVolume = new Map<string, boolean>();
    public Map<decimal, SectionWrapper> subBrandSectionMap = new Map<decimal, SectionWrapper>();
    //public Boolean isPageInit { get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}
    public Map<string, Map<string, boolean>> map_type_isDisplayRow = new Map<string, Map<string, boolean>>();
  
    public PageReference pageRef = ApexPages.currentPage();
    
    //Execute the logic when contract id is setted by component
    public Boolean init(){
        loadStaticResource();
        
        contractList = retrieveContractList(pafId);
        Set<String> customerIdSet_all = new Set<String>();
        Set<String> customerIdSet_cpParent = new Set<String>();
        
        
        //Just One record 
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : contractList){
            if(paf.ASI_HK_CRM_PAF_Customer2__c!=null)
                customerIdSet_all.add(paf.ASI_HK_CRM_PAF_Customer2__c);
            if(paf.ASI_HK_CRM_PAF_Customer3__c!=null)
                customerIdSet_all.add(paf.ASI_HK_CRM_PAF_Customer3__c);
            if(paf.ASI_HK_CRM_PAF_Customer4__c!=null)
                customerIdSet_all.add(paf.ASI_HK_CRM_PAF_Customer4__c);
            
            contractIdList.add(paf.Id);
            map_paf_includeVolume.put(paf.Id, true);
            if(paf.ASI_CRM_HK_PAF_no__c != null){
                contractIdList.add(paf.ASI_CRM_HK_PAF_no__c);
                currentPAFIdList.add(paf.ASI_CRM_HK_PAF_no__c);
                //map_paf_includeVolume.put(paf.ASI_CRM_HK_PAF_no__c, paf.ASI_CRM_HK_Pl_volume1__c);
                // Always include volume of 1st reference PAF
                map_paf_includeVolume.put(paf.ASI_CRM_HK_PAF_no__c, true);
                customerIdSet_cpParent.add(paf.ASI_CRM_HK_PAF_no__r.ASI_HK_CRM_PAF_Customer__c);
            }
            if(paf.ASI_CRM_HK_PAF_no_2__c != null){
                contractIdList.add(paf.ASI_CRM_HK_PAF_no_2__c);
                currentPAFIdList.add(paf.ASI_CRM_HK_PAF_no_2__c);
                map_paf_includeVolume.put(paf.ASI_CRM_HK_PAF_no_2__c, paf.ASI_CRM_HK_Pl_volume2__c);
                customerIdSet_cpParent.add(paf.ASI_CRM_HK_PAF_no_2__r.ASI_HK_CRM_PAF_Customer__c);
            }
            if(paf.ASI_CRM_HK_PAF_no_3__c != null){
                contractIdList.add(paf.ASI_CRM_HK_PAF_no_3__c);
                currentPAFIdList.add(paf.ASI_CRM_HK_PAF_no_3__c);
                map_paf_includeVolume.put(paf.ASI_CRM_HK_PAF_no_3__c, paf.ASI_CRM_HK_Pl_volume3__c);
                customerIdSet_cpParent.add(paf.ASI_CRM_HK_PAF_no_3__r.ASI_HK_CRM_PAF_Customer__c);
            }
            if(paf.ASI_CRM_HK_PAF_no_4__c != null){
                contractIdList.add(paf.ASI_CRM_HK_PAF_no_4__c);
                currentPAFIdList.add(paf.ASI_CRM_HK_PAF_no_4__c);
                map_paf_includeVolume.put(paf.ASI_CRM_HK_PAF_no_4__c, paf.ASI_CRM_HK_Pl_volume4__c);
                customerIdSet_cpParent.add(paf.ASI_CRM_HK_PAF_no_4__r.ASI_HK_CRM_PAF_Customer__c);
            }
            if(paf.ASI_CRM_HK_PAF_no_5__c != null){
                contractIdList.add(paf.ASI_CRM_HK_PAF_no_5__c);
                currentPAFIdList.add(paf.ASI_CRM_HK_PAF_no_5__c);
                map_paf_includeVolume.put(paf.ASI_CRM_HK_PAF_no_5__c, paf.ASI_CRM_HK_Pl_volume5__c);
                customerIdSet_cpParent.add(paf.ASI_CRM_HK_PAF_no_5__r.ASI_HK_CRM_PAF_Customer__c);
            }
        }
        
        if(contractList[0].ASI_CRM_Short_Term_Promotion__c){
            for(ASI_CRM_HK_Pre_Approval_Form_Customer__c PAFCustomer:[
                select id,ASI_CRM_HK_Customer__c 
                from ASI_CRM_HK_Pre_Approval_Form_Customer__c 
                where ASI_CRM_HK_Customer__c!=null 
                and ASI_CRM_HK_Pre_Approval_Form__c = :contractList[0].id
            ]){
                customerIdSet_all.add(PAFCustomer.ASI_CRM_HK_Customer__c);
            }
        }  else {
            if(contractList[0].ASI_HK_CRM_PAF_Customer__c!=null)
                customerIdSet_all.add(contractList[0].ASI_HK_CRM_PAF_Customer__c);
        }
        
        
        compareContract(pafId, currentPAFIdList, contractIdList, customerIdSet_all, customerIdSet_cpParent);
        return true;
    }
    
    public void compareContract(String baseContractId, Set<String> currentPAFIdList, List<String> contractIdList, Set<String> customerIdSet_all, Set<String> customerIdSet_cpParent ) {
        //Init wrapperList
        contractComparisonResultWrapperList = new List<ContractComparisonResultWrapper>();
        
        //Get the base contract and remove it in the map
        List<ASI_HK_CRM_Pre_Approval_Form__c> baseContract = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
        List<ASI_HK_CRM_Pre_Approval_Form__c> currentContract = new List<ASI_HK_CRM_Pre_Approval_Form__c>();
        ASI_HK_CRM_Pre_Approval_Form__c proposedPAF;

        //Retrieve the contract records that need to be compared
        for(ASI_HK_CRM_Pre_Approval_Form__c paf : retrieveContractWithChildList(contractIdList)){
            if(paf.Id == baseContractId){ // this PAF itself
                baseContract.add(paf);
                proposedPAF = paf;
            } else if(currentPAFIdList.contains(paf.Id)){ // other P&L - Reference PAF, no need to check contains
                currentContract.add(paf);
            }
        }
        
        /*
        map<string, ASI_CRM_PnL_Cost__c> map_PnLCost_budget = retrievePnLCostList_budget(proposedPAF);
        map<string, ASI_CRM_PnL_Cost__c> map_PnLCost_actual = retrievePnLCostList_actual(proposedPAF, customerIdSet_cpParent);
        map_PnLCost_actual.putAll(map_PnLCost_budget);
        map<string, ASI_CRM_PnL_Cost__c> map_PnLCost = map_PnLCost_actual;
        */
        map<string, ASI_CRM_PnL_Cost__c> map_PnLCost = retrievePnLCostList(proposedPAF);
        
        boolean hasCurrent = currentPAFIdList.size()>0 ? true : false;
        boolean hasActual = (proposedPAF.ASI_CRM_Ref_Start_Date__c != null && proposedPAF.ASI_CRM_Ref_End_Date__c != null && customerIdSet_all.size() > 0) ? true : false;
        
        if(hasActual && isActualBreakdown){
            Map<string, list<AggregateResult>> map_customer_listAr = new Map<string, list<AggregateResult>>();
            Map<string, string> map_customerName = retrieveCustomerName(customerIdSet_all);
            for(AggregateResult ar : retrieveActualPnLListByCustomer(proposedPAF, customerIdSet_all)){
                string parent = string.valueOf(ar.get('parent'));
                string child = string.valueOf(ar.get('child'));
                if(customerIdSet_all.contains(parent)){
                    list<AggregateResult> list_ar = map_customer_listAr.containsKey(parent) ? map_customer_listAr.get(parent) : new list<AggregateResult>();
                    list_ar.add(ar);
                    map_customer_listAr.put(parent, list_ar);
                }
                if(customerIdSet_all.contains(child)){
                    list<AggregateResult> list_ar = map_customer_listAr.containsKey(child) ? map_customer_listAr.get(child) : new list<AggregateResult>();
                    list_ar.add(ar);
                    map_customer_listAr.put(child, list_ar);
                }
            }
            for(string customerId : map_customer_listAr.keySet()){
                ContractComparisonResultWrapper w = new ContractComparisonResultWrapper('Actual', false, proposedPAF, subBrandSectionMap, map_customer_listAr.get(customerId), map_PnLCost);
                w.customerName = map_customerName.get(customerId);
                contractComparisonResultWrapperList.add(w);
            }
        } else {
            ContractComparisonResultWrapper currentComparisonResultWrapper = hasCurrent ? 
                new ContractComparisonResultWrapper('Current', false, proposedPAF, currentContract, subBrandSectionMap, map_paf_includeVolume, map_PnLCost) :
                new ContractComparisonResultWrapper('Current');
            /*
            if(hasCurrent){
                currentComparisonResultWrapper = new ContractComparisonResultWrapper('Current', false, proposedPAF, currentContract, subBrandSectionMap, map_paf_includeVolume, map_PnLCost);
            }
            */
            contractComparisonResultWrapperList.add(currentComparisonResultWrapper);
          
            ContractComparisonResultWrapper actualComparisonResultWrapper;
            if(hasActual){
                List<AggregateResult> list_actualPnL = retrieveActualPnLList(proposedPAF, customerIdSet_all);
                actualComparisonResultWrapper = new ContractComparisonResultWrapper('Actual', false, proposedPAF, subBrandSectionMap, list_actualPnL, map_PnLCost);
            }else{
                actualComparisonResultWrapper = new ContractComparisonResultWrapper('Actual');
            }
            contractComparisonResultWrapperList.add(actualComparisonResultWrapper);
            
            ContractComparisonResultWrapper proposedComparisonResultWrapper = new ContractComparisonResultWrapper('Proposed', true, proposedPAF, baseContract, subBrandSectionMap, map_paf_includeVolume, map_PnLCost);
            contractComparisonResultWrapperList.add(proposedComparisonResultWrapper);

            /*
            if(hasActual && hasCurrent){
                ContractComparisonResultWrapper acContractComparisonResultWrapper = new ContractComparisonResultWrapper('Act vs Current', actualComparisonResultWrapper, currentComparisonResultWrapper);
                contractComparisonResultWrapperList.add(acContractComparisonResultWrapper);
            }
            if(hasActual){
                ContractComparisonResultWrapper paContractComparisonResultWrapper = new ContractComparisonResultWrapper('Proposed vs Act', proposedComparisonResultWrapper, actualComparisonResultWrapper);
                contractComparisonResultWrapperList.add(paContractComparisonResultWrapper);
            } 
            if(hasCurrent){
                ContractComparisonResultWrapper pcContractComparisonResultWrapper = new ContractComparisonResultWrapper('Proposed vs Current', proposedComparisonResultWrapper, currentComparisonResultWrapper);
                contractComparisonResultWrapperList.add(pcContractComparisonResultWrapper);
            }
            */
            ContractComparisonResultWrapper acContractComparisonResultWrapper = (hasActual && hasCurrent) ? 
                new ContractComparisonResultWrapper('Act vs Current', actualComparisonResultWrapper, currentComparisonResultWrapper) :
                new ContractComparisonResultWrapper('Act vs Current');
            contractComparisonResultWrapperList.add(acContractComparisonResultWrapper);
                
            ContractComparisonResultWrapper paContractComparisonResultWrapper = hasActual ? 
                new ContractComparisonResultWrapper('Proposed vs Act', proposedComparisonResultWrapper, actualComparisonResultWrapper) :
                new ContractComparisonResultWrapper('Proposed vs Act');
            contractComparisonResultWrapperList.add(paContractComparisonResultWrapper);
                
            ContractComparisonResultWrapper pcContractComparisonResultWrapper = hasCurrent ? 
                new ContractComparisonResultWrapper('Proposed vs Current', proposedComparisonResultWrapper, currentComparisonResultWrapper) :
                new ContractComparisonResultWrapper('Proposed vs Current');
            contractComparisonResultWrapperList.add(pcContractComparisonResultWrapper);
            
        }
        
        checkRowsToDisplay(contractComparisonResultWrapperList, subBrandSectionMap);
    }
    
    public void checkRowsToDisplay(List<ContractComparisonResultWrapper> contractComparisonResultWrapperList, Map<decimal, SectionWrapper> subBrandSectionMap){
        
        map_type_isDisplayRow.put('Volume9L', initiateIsDisplayBrand(subBrandSectionMap));
        map_type_isDisplayRow.put('NNPper9L', initiateIsDisplayBrand(subBrandSectionMap));
        map_type_isDisplayRow.put('Financial', initiateFinancial());
        
        checkRowsToDisplayWithData(contractComparisonResultWrapperList);
    }
    
    public Map<string, boolean> initiateIsDisplayBrand(Map<decimal, SectionWrapper> subBrandSectionMap){
        map<string, boolean> map_subBrand_false = new map<string, boolean>();
        for(SectionWrapper w : subBrandSectionMap.values()){
            map_subBrand_false.put(w.displayName, false);
            map_subBrand_false.put(w.displayName+'_others', false);
            if(w.hasSubSection){
                for(SectionWrapper sw : w.subSectionMap.values()){
                    map_subBrand_false.put(sw.displayName, false);
                }
            }
        }
        map_subBrand_false.put('Others', false);
        map_subBrand_false.put('total', false);
        return map_subBrand_false;
    }
    
    public Map<string, boolean> initiateFinancial(){
        map<string, boolean> map_financial_false = new map<string, boolean>();
        
        map_financial_false.put('A01',false);
        map_financial_false.put('A02',false);
        map_financial_false.put('A03',false);
        map_financial_false.put('A04',false);
        map_financial_false.put('A05',false);
        map_financial_false.put('A06',false);
        map_financial_false.put('A07',false);
        map_financial_false.put('A08',false);
        map_financial_false.put('A09',false);
        map_financial_false.put('A10',false);
        map_financial_false.put('A11',false);
        map_financial_false.put('A12',false);
        map_financial_false.put('A13',false);
        map_financial_false.put('A14',false);
        map_financial_false.put('A15',false);
        map_financial_false.put('A16',false);
        map_financial_false.put('A17',false);
        map_financial_false.put('B01',false);
        map_financial_false.put('B02',false);
        map_financial_false.put('B03',false);
        map_financial_false.put('B04',false);
        map_financial_false.put('B05',false);
        map_financial_false.put('B06',false);
        map_financial_false.put('B07',false);
        map_financial_false.put('B08',false);
        map_financial_false.put('B09',false);
        map_financial_false.put('B10',false);
        map_financial_false.put('B11',false);
        map_financial_false.put('B12',false);
        map_financial_false.put('B13',false);
        map_financial_false.put('B14',false);
        // display all subtotal
        map_financial_false.put('SalesValue',true);
        map_financial_false.put('TotalInvestmentBeforeNetSales',true);
        map_financial_false.put('NetSales',true);
        map_financial_false.put('Cost',true);
        map_financial_false.put('CM',true);
        map_financial_false.put('TotalInvestmentAfterNetSales',true);
        map_financial_false.put('CAAP',true);
        map_financial_false.put('TotalInvestment',true);
        map_financial_false.put('TotalInvestmentPercentOfSalesValues',true);
        map_financial_false.put('ROIPercent',true);
        map_financial_false.put('VariableInvestment',true);
        map_financial_false.put('FixedInvestment',true);

        return map_financial_false;
    }
    
    public void checkRowsToDisplayWithData(List<ContractComparisonResultWrapper> contractComparisonResultWrapperList){
        for(ContractComparisonResultWrapper cW : contractComparisonResultWrapperList){
            if(!cW.needCheckDisplay) continue;
            if(cW.map_type_dW == null) continue;
            
            // check Volume9L
            for(string displayName : map_type_isDisplayRow.get('Volume9L').keySet()){
                if(cW.map_type_dW.get(displayName).Volume9L != 0){
                    map_type_isDisplayRow.get('Volume9L').put(displayName, true);
                }
            }
            // check NNPper9L
            for(string displayName : map_type_isDisplayRow.get('NNPper9L').keySet()){
                if(cW.map_type_dW.get(displayName).Volume9L != 0){
                    map_type_isDisplayRow.get('NNPper9L').put(displayName, true);
                }
            }
            // check Financial
            if(cW.map_type_dW.get('total').A01 != 0){ map_type_isDisplayRow.get('Financial').put('A01', true); }
            if(cW.map_type_dW.get('total').A02 != 0){ map_type_isDisplayRow.get('Financial').put('A02', true); }
            if(cW.map_type_dW.get('total').A03 != 0){ map_type_isDisplayRow.get('Financial').put('A03', true); }
            if(cW.map_type_dW.get('total').A04 != 0){ map_type_isDisplayRow.get('Financial').put('A04', true); }
            if(cW.map_type_dW.get('total').A05 != 0){ map_type_isDisplayRow.get('Financial').put('A05', true); }
            if(cW.map_type_dW.get('total').A06 != 0){ map_type_isDisplayRow.get('Financial').put('A06', true); }
            if(cW.map_type_dW.get('total').A07 != 0){ map_type_isDisplayRow.get('Financial').put('A07', true); }
            if(cW.map_type_dW.get('total').A08 != 0){ map_type_isDisplayRow.get('Financial').put('A08', true); }
            if(cW.map_type_dW.get('total').A09 != 0){ map_type_isDisplayRow.get('Financial').put('A09', true); }
            if(cW.map_type_dW.get('total').A10 != 0){ map_type_isDisplayRow.get('Financial').put('A10', true); }
            if(cW.map_type_dW.get('total').A11 != 0){ map_type_isDisplayRow.get('Financial').put('A11', true); }
            if(cW.map_type_dW.get('total').A12 != 0){ map_type_isDisplayRow.get('Financial').put('A12', true); }
            if(cW.map_type_dW.get('total').A13 != 0){ map_type_isDisplayRow.get('Financial').put('A13', true); }
            if(cW.map_type_dW.get('total').A14 != 0){ map_type_isDisplayRow.get('Financial').put('A14', true); }
            if(cW.map_type_dW.get('total').A15 != 0){ map_type_isDisplayRow.get('Financial').put('A15', true); }
            if(cW.map_type_dW.get('total').A16 != 0){ map_type_isDisplayRow.get('Financial').put('A16', true); }
            if(cW.map_type_dW.get('total').A17 != 0){ map_type_isDisplayRow.get('Financial').put('A17', true); }
            if(cW.map_type_dW.get('total').B01 != 0){ map_type_isDisplayRow.get('Financial').put('B01', true); }
            if(cW.map_type_dW.get('total').B02 != 0){ map_type_isDisplayRow.get('Financial').put('B02', true); }
            if(cW.map_type_dW.get('total').B03 != 0){ map_type_isDisplayRow.get('Financial').put('B03', true); }
            if(cW.map_type_dW.get('total').B04 != 0){ map_type_isDisplayRow.get('Financial').put('B04', true); }
            if(cW.map_type_dW.get('total').B05 != 0){ map_type_isDisplayRow.get('Financial').put('B05', true); }
            if(cW.map_type_dW.get('total').B06 != 0){ map_type_isDisplayRow.get('Financial').put('B06', true); }
            if(cW.map_type_dW.get('total').B07 != 0){ map_type_isDisplayRow.get('Financial').put('B07', true); }
            if(cW.map_type_dW.get('total').B08 != 0){ map_type_isDisplayRow.get('Financial').put('B08', true); }
            if(cW.map_type_dW.get('total').B09 != 0){ map_type_isDisplayRow.get('Financial').put('B09', true); }
            if(cW.map_type_dW.get('total').B10 != 0){ map_type_isDisplayRow.get('Financial').put('B10', true); }
            if(cW.map_type_dW.get('total').B11 != 0){ map_type_isDisplayRow.get('Financial').put('B11', true); }
            if(cW.map_type_dW.get('total').B12 != 0){ map_type_isDisplayRow.get('Financial').put('B12', true); }
            if(cW.map_type_dW.get('total').B13 != 0){ map_type_isDisplayRow.get('Financial').put('B13', true); }
            if(cW.map_type_dW.get('total').B14 != 0){ map_type_isDisplayRow.get('Financial').put('B14', true); }
            if(cW.map_type_dW.get('total').SalesValue != 0){ map_type_isDisplayRow.get('Financial').put('SalesValue', true); }
            if(cW.map_type_dW.get('total').TotalInvestmentBeforeNetSales != 0){ map_type_isDisplayRow.get('Financial').put('TotalInvestmentBeforeNetSales', true); }
            if(cW.map_type_dW.get('total').NetSales != 0){ map_type_isDisplayRow.get('Financial').put('NetSales', true); }
            if(cW.map_type_dW.get('total').Cost != 0){ map_type_isDisplayRow.get('Financial').put('Cost', true); }
            if(cW.map_type_dW.get('total').CM != 0){ map_type_isDisplayRow.get('Financial').put('CM', true); }
            if(cW.map_type_dW.get('total').TotalInvestmentAfterNetSales != 0){ map_type_isDisplayRow.get('Financial').put('TotalInvestmentAfterNetSales', true); }
            if(cW.map_type_dW.get('total').CAAP != 0){ map_type_isDisplayRow.get('Financial').put('CAAP', true); }
            if(cW.map_type_dW.get('total').TotalInvestment != 0){ map_type_isDisplayRow.get('Financial').put('TotalInvestment', true); }
            if(cW.map_type_dW.get('total').TotalInvestmentPercentOfSalesValues != 0){ map_type_isDisplayRow.get('Financial').put('TotalInvestmentPercentOfSalesValues', true); }
            if(cW.map_type_dW.get('total').ROIPercent != 0){ map_type_isDisplayRow.get('Financial').put('ROIPercent', true); }
            if(cW.map_type_dW.get('total').VariableInvestment != 0){ map_type_isDisplayRow.get('Financial').put('VariableInvestment', true); }
            if(cW.map_type_dW.get('total').FixedInvestment != 0){ map_type_isDisplayRow.get('Financial').put('FixedInvestment', true); }

        }
    }
    
    /***************
    XML Static Resource Function
    ***************/
    //Wrapper Class for storing all section
    public class SectionWrapper {
        public String name                                {get; set;}
        public String code                               {get; set;}
        public String recordId                               {get; set;}
        public Set<string> set_recordId                               {get; set;}
        public String displayName                               {get; set;}
        public Integer sortingNumber                               {get; set;}
        public boolean hasOthers                             {get; set;}
        public boolean isSubBrand                    {get; set;}
        public boolean displayNNP                    {get; set;}
        public Map<decimal, SectionWrapper> subSectionMap {get; set;}
        public Boolean hasSubSection                      {get; set;}
        
        public SectionWrapper(String name, String code, /*String recordId,*/set<String> set_recordId, Boolean hasOthers, boolean isSubBrand, String displayName, Integer sortingNumber, boolean displayNNP, 
                              Map<decimal, SectionWrapper> subSectionMap) {
            this.name          = name;
            //this.recordId         = recordId;
            //this.set_recordId         = new Set<String>(recordId.split(';'));
            this.set_recordId = set_recordId;
            this.displayName         = displayName;
            this.hasOthers = hasOthers;
            this.isSubBrand = isSubBrand;
            this.displayNNP = displayNNP;
            this.sortingNumber = sortingNumber;
            this.subSectionMap = subSectionMap;
            this.code = code;
            
            if(subSectionMap == null || subSectionMap.size() == 0) {
                hasSubSection = false; 
            } else {
              hasSubSection = true;
            }
            
        }
    }
    
    private void loadStaticResource() {
        String xmlStr ='';
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = 'ASI_CRM_HK_PAFPnLReport_Structure' LIMIT 1];
        xmlStr = sr.Body.toString(); 
        
        
        Dom.Document doc = new Dom.Document();
        doc.load(xmlStr);
        
        Dom.XMLNode docRootNode  = doc.getRootElement();
    
        subBrandSectionMap = parseXML(docRootNode);
    }
    
    private Map<decimal, SectionWrapper> parseXML(Dom.XMLNode sectionNode) {
        Map<decimal, SectionWrapper> sectionWrapperMap = new Map<decimal, SectionWrapper>();
        List<ASI_MFM_Sub_brand__c> list_sb = retrieveSubBrandList();
        
        map<string, string> map_subBrandCode = new map<string, string>();
        map<string, string> map_brandCode = new map<string, string>();
        for(ASI_MFM_Sub_brand__c sb : list_sb){
            map_subBrandCode.put(sb.ASI_MFM_Sub_brand_Code__c, sb.id);
            map_brandCode.put(sb.ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c, sb.ASI_MFM_Brand__c);
        }
        
        for(Dom.XMLNode childNode : sectionNode.getChildElements()) {
            String name                                = childNode.getAttribute('name', null);
            //String recordId                               = childNode.getChildElement('recordId', null).getText();
            String displayName                               = childNode.getChildElement('displayName', null).getText();
            Boolean hasOthers                      = Boolean.valueOf(childNode.getChildElement('hasOthers', null).getText());
            Boolean isSubBrand                      = Boolean.valueOf(childNode.getChildElement('isSubBrand', null).getText());
            Boolean displayNNP                      = Boolean.valueOf(childNode.getChildElement('displayNNP', null).getText());
            Integer sortingNumber                       = Integer.valueOf(childNode.getChildElement('sortingNumber', null).getText());
            String code                                = childNode.getChildElement('code', null).getText();
            Map<decimal, SectionWrapper> subSectionMap = null;
            
            Set<string> set_codeId = new set<string>();
            Set<String> set_code = new Set<String>(code.split(';'));
            for(string c : set_code){
                if(isSubBrand){
                    if(map_subBrandCode.containsKey(c)) set_codeId.add(map_subBrandCode.get(c));
                }else {
                    if(map_brandCode.containsKey(c)) set_codeId.add(map_brandCode.get(c));
                }
            }
            
            Dom.XMLNode subSectionNode = childNode.getChildElement('subSection', null);
            if(subSectionNode != null) {
                subSectionMap = parseXML(subSectionNode);
            }

            SectionWrapper sectionWrapper = new SectionWrapper(name, code, /*recordId,*/set_codeId, hasOthers, isSubBrand, displayName, sortingNumber, displayNNP, subSectionMap);
            sectionWrapperMap.put(sortingNumber, sectionWrapper);
        }
        
        return sectionWrapperMap;
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private List<ASI_MFM_Sub_brand__c> retrieveSubBrandList() {
        return [SELECT id, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Brand__c, ASI_MFM_Brand__r.ASI_MFM_Brand_Code__c 
                       FROM ASI_MFM_Sub_brand__c 
                       WHERE RecordType.DeveloperName = 'ASI_HK_CRM_Sub_brand'];

        //return (List<ASI_MFM_Sub_brand__c>) Database.query(query);
    }
  
    private List<ASI_HK_CRM_Pre_Approval_Form__c> retrieveContractList(string paf) {
        String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST_SIMPLE) + ', ' +
            'RecordType.DeveloperName ' +
                       'FROM ASI_HK_CRM_Pre_Approval_Form__c ' +
                       'WHERE id = : pafId';

        List<ASI_HK_CRM_Pre_Approval_Form__c> contractList = (List<ASI_HK_CRM_Pre_Approval_Form__c>) Database.query(query);
        return contractList.size() > 0 ? contractList : new List<ASI_HK_CRM_Pre_Approval_Form__c>();
    }
  
    private List<ASI_HK_CRM_Pre_Approval_Form__c> retrieveContractWithChildList(List<string> contractIdList) {
        String query = 'SELECT ' + genQueryFieldFromList(CONTRACT_FIELD_LIST_SIMPLE) +
                       ', RecordType.DeveloperName, ' +
                       //Retrieve Actual Offtake
                       '(SELECT ' + genQueryFieldFromList(MECHANICS_FIELD_LIST) + ' FROM Pre_Approval_Form_Items_Link_To_PAF_Form__r) ' + 
                       'FROM ASI_HK_CRM_Pre_Approval_Form__c ' +
                       'WHERE Id in : contractIdList';

        List<ASI_HK_CRM_Pre_Approval_Form__c> contractList = (List<ASI_HK_CRM_Pre_Approval_Form__c>) Database.query(query);
        return contractList.size() > 0 ? contractList : new List<ASI_HK_CRM_Pre_Approval_Form__c>();
    }

    private List<AggregateResult> retrieveActualPnLList(ASI_HK_CRM_Pre_Approval_Form__c proposedPAF, Set<string> customerIdSet_all) {
        Date startDate = Date.newinstance(proposedPAF.ASI_CRM_Ref_Start_Date__c.year(), proposedPAF.ASI_CRM_Ref_Start_Date__c.month(),1);
        Date endDate = Date.newinstance(proposedPAF.ASI_CRM_Ref_End_Date__c.year(), proposedPAF.ASI_CRM_Ref_End_Date__c.month(),1).addMonths(1);
        List<AggregateResult> contractList = [
            select 
                ASI_CRM_Sub_Brand__c subBrandId,
                ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c brandId,
                ASI_CRM_Object_Key__c objectKey,
                ASI_CRM_Line_Type__c lineType,
                sum(ASI_CRM_Volume_9L_MTD__c) volume9L,
                sum(ASI_CRM_Total_Cost_MTD__c) value 
            from ASI_CRM_PnL_Cost__c
            where 
                recordtype.developername = 'ASI_CRM_HK_Customer_Actual' and
                ASI_CRM_Sub_Brand__c != null and 
                (ASI_CRM_Customer_Number_PA__c in : customerIdSet_all  or ASI_CRM_Customer_Number_DA__c in :customerIdSet_all ) and
                ASI_CRM_Period_Begin_Date__c >= :startDate and
                ASI_CRM_Period_End_Date__c < :endDate 
            group by 
                ASI_CRM_Sub_Brand__c,
                ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c,
                ASI_CRM_Object_Key__c,
                ASI_CRM_Line_Type__c
        ];
        return contractList.size() > 0 ? contractList : new List<AggregateResult>();
    }

    private List<AggregateResult> retrieveActualPnLListByCustomer(ASI_HK_CRM_Pre_Approval_Form__c proposedPAF, Set<string> customerIdSet_all) {
        Date startDate = Date.newinstance(proposedPAF.ASI_CRM_Ref_Start_Date__c.year(), proposedPAF.ASI_CRM_Ref_Start_Date__c.month(),1);
        Date endDate = Date.newinstance(proposedPAF.ASI_CRM_Ref_End_Date__c.year(), proposedPAF.ASI_CRM_Ref_End_Date__c.month(),1).addMonths(1);
        List<AggregateResult> contractList = [
            select 
                ASI_CRM_Customer_Number_PA__c parent,
                ASI_CRM_Customer_Number_DA__c child,
                ASI_CRM_Sub_Brand__c subBrandId,
                ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c brandId,
                ASI_CRM_Object_Key__c objectKey,
                ASI_CRM_Line_Type__c lineType,
                sum(ASI_CRM_Volume_9L_MTD__c) volume9L,
                sum(ASI_CRM_Total_Cost_MTD__c) value 
            from ASI_CRM_PnL_Cost__c
            where 
                recordtype.developername = 'ASI_CRM_HK_Customer_Actual' and
                ASI_CRM_Sub_Brand__c != null and 
                (ASI_CRM_Customer_Number_PA__c in : customerIdSet_all  or ASI_CRM_Customer_Number_DA__c in :customerIdSet_all ) and
                ASI_CRM_Period_Begin_Date__c >= :startDate and
                ASI_CRM_Period_End_Date__c < :endDate 
            group by 
                ASI_CRM_Customer_Number_PA__c,
                ASI_CRM_Customer_Number_DA__c,
                ASI_CRM_Sub_Brand__c,
                ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c,
                ASI_CRM_Object_Key__c,
                ASI_CRM_Line_Type__c
        ];
        return contractList.size() > 0 ? contractList : new List<AggregateResult>();
    }
    
    private map<string, string> retrieveCustomerName(Set<string> customerIdSet_all){
        map<string, string> map_customerName = new map<string, string>();
        for(account a : [select id, name from account where id in :customerIdSet_all]){
            map_customerName.put(a.id, a.name);
        }
        return map_customerName;
    }

    private map<string, ASI_CRM_PnL_Cost__c> retrievePnLCostList(ASI_HK_CRM_Pre_Approval_Form__c proposedPAF) {
        Map<String,ASI_CRM_PnL_Cost__c> PnLCostMap= new Map<String,ASI_CRM_PnL_Cost__c>();
        
        Date inputDate = proposedPAF.ASI_HK_CRM_Adjusted_Start_Date__c;
        Date LastDateOfThisFY = Date.newinstance(inputDate.year(), 6,30);
        if(inputDate.month() >= 7){
            LastDateOfThisFY = LastDateOfThisFY.addYears(1);
        }
        Date LastDateOfLastFY = LastDateOfThisFY.addYears(-1);
        
        for(ASI_CRM_PnL_Cost__c pnlcost : [
            select Id, 
                ASI_CRM_Sub_Brand__c,
                ASI_CRM_Cost_per_9L_YTD__c, 
                ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c, 
                ASI_CRM_Period_End_Date__c,
                RecordType.DeveloperName  
            from ASI_CRM_PnL_Cost__c
            where 
                recordtypeid in :LIST_RTID_BUDGETACTUALCOST and
                ASI_CRM_Cost_per_9L_YTD__c != 0 and
                (ASI_CRM_Period_End_Date__c = :LastDateOfThisFY or ASI_CRM_Period_End_Date__c = :LastDateOfLastFY)
                
        ]){
            String PnLKey ='';
            if(pnlcost.ASI_CRM_Sub_Brand__c!=null){
                //Record type+Sub-Brand + Period End Date
                PnLKey=pnlcost.RecordType.DeveloperName + pnlcost.ASI_CRM_Sub_Brand__c +string.valueOf(pnlcost.ASI_CRM_Period_End_Date__c);
                
                PnLCostMap.put(PnLKey, pnlcost);
            }
            
            if(pnlcost.ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c!=null){
                PnLKey = pnlcost.RecordType.DeveloperName + pnlcost.ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c +string.valueOf(pnlcost.ASI_CRM_Period_End_Date__c);
                PnLCostMap.put(PnLKey, pnlcost);
            } 
        }
        return PnLCostMap;
    }

    /*
    private map<string, ASI_CRM_PnL_Cost__c> retrievePnLCostList_budget(ASI_HK_CRM_Pre_Approval_Form__c proposedPAF) {
        Map<String,ASI_CRM_PnL_Cost__c> PnLCostMap= new Map<String,ASI_CRM_PnL_Cost__c>();
        
        Date inputDate = proposedPAF.ASI_HK_CRM_Adjusted_Start_Date__c;
        Date LastDateOfThisFY = Date.newinstance(inputDate.year(), 6,30);
        if(inputDate.month() >= 7){
            LastDateOfThisFY = LastDateOfThisFY.addYears(1);
        }
        Date LastDateOfLastFY = LastDateOfThisFY.addYears(-1);
        
        for(ASI_CRM_PnL_Cost__c pnlcost : [
            select Id, 
                ASI_CRM_Sub_Brand__c,
                ASI_CRM_Cost_per_9L_YTD__c, 
                ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c, 
                ASI_CRM_Period_End_Date__c,
                RecordType.DeveloperName  
            from ASI_CRM_PnL_Cost__c
            where 
                recordtypeid in :LIST_RTID_BUDGETCOST and
                ASI_CRM_Cost_per_9L_YTD__c != 0 and
                ASI_CRM_Period_End_Date__c = :LastDateOfThisFY
                
        ]){
            String PnLKey ='';
            if(pnlcost.ASI_CRM_Sub_Brand__c!=null){
                //Record type+Sub-Brand + Period End Date
                PnLKey=pnlcost.RecordType.DeveloperName + pnlcost.ASI_CRM_Sub_Brand__c +string.valueOf(pnlcost.ASI_CRM_Period_End_Date__c);
                
                PnLCostMap.put(PnLKey, pnlcost);
            }
            
            if(pnlcost.ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c!=null){
                PnLKey = pnlcost.RecordType.DeveloperName + pnlcost.ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c +string.valueOf(pnlcost.ASI_CRM_Period_End_Date__c);
                PnLCostMap.put(PnLKey, pnlcost);
            } 
        }
        return PnLCostMap;
    }

    private map<string, ASI_CRM_PnL_Cost__c> retrievePnLCostList_actual(ASI_HK_CRM_Pre_Approval_Form__c proposedPAF, set<string> set_customerId) {
        Map<String,ASI_CRM_PnL_Cost__c> PnLCostMap= new Map<String,ASI_CRM_PnL_Cost__c>();
        
        Date inputDate = proposedPAF.ASI_HK_CRM_Adjusted_Start_Date__c;
        Date LastDateOfThisFY = Date.newinstance(inputDate.year(), 6,30);
        if(inputDate.month() >= 7){
            LastDateOfThisFY = LastDateOfThisFY.addYears(1);
        }
        Date LastDateOfLastFY = LastDateOfThisFY.addYears(-1);
        
        for(ASI_CRM_PnL_Cost__c pnlcost : [
            select Id, 
                ASI_CRM_Customer_Number_PA__c,
                ASI_CRM_Sub_Brand__c,
                ASI_CRM_Cost_per_9L_YTD__c, 
                ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c, 
                ASI_CRM_Period_End_Date__c,
                RecordType.DeveloperName  
            from ASI_CRM_PnL_Cost__c
            where 
                recordtypeid in :LIST_RTID_ACTUALCOST and
                ASI_CRM_Customer_Number_PA__c in :set_customerId and
                ASI_CRM_Cost_per_9L_YTD__c != 0 and
                (ASI_CRM_Period_End_Date__c = :LastDateOfThisFY or ASI_CRM_Period_End_Date__c = :LastDateOfLastFY)
                
        ]){
            String PnLKey ='';
            if(pnlcost.ASI_CRM_Sub_Brand__c!=null){
                //Record type+Sub-Brand + Period End Date
                PnLKey=pnlcost.RecordType.DeveloperName + pnlcost.ASI_CRM_Customer_Number_PA__c + pnlcost.ASI_CRM_Sub_Brand__c +string.valueOf(pnlcost.ASI_CRM_Period_End_Date__c);
                
                PnLCostMap.put(PnLKey, pnlcost);
            }
            
            if(pnlcost.ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c!=null){
                PnLKey = pnlcost.RecordType.DeveloperName + pnlcost.ASI_CRM_Customer_Number_PA__c + pnlcost.ASI_CRM_Sub_Brand__r.ASI_MFM_Brand__c +string.valueOf(pnlcost.ASI_CRM_Period_End_Date__c);
                PnLCostMap.put(PnLKey, pnlcost);
            } 
        }
        return PnLCostMap;
    }
    */

    /***************
    Tools Function
    ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    private String genQueryFieldFromList(list<string> fieldList) {
        return String.join(fieldList, ',');
    }

    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private List<Object> fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return (List<Object>) System.JSON.deserialize(jsonString, apexType);
    }

    public string inputEndDate{
        get{
      Datetime dt = System.now();            
            return dt.format('YYYY-MM-dd');
        }
        set;
    }
  
    public string inputStartDate{
        get{
      Datetime dt = System.now().addYears(-2);            
            return dt.format('YYYY-MM-dd');
        }
        set;
    }
  
    public void printPDF(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        
        ASI_MFM_Mass_Upload_Log__c uploadLog = new ASI_MFM_Mass_Upload_Log__c();
        insert uploadLog;
        Attachment tempAttached = new Attachment();
        tempAttached.ParentId = uploadLog.Id;
        tempAttached.Name = 'HK PnL PDF';
        tempAttached.Body = Blob.valueOf(params.get('resultHTML'));
        insert tempAttached;
        
        system.debug(tempAttached);
        
        fileId = tempAttached.Id;
        system.debug(returnFileId);
    }
    
    public void buildResult(){
        Attachment tempAttachment = [SELECT Body, ParentId FROM Attachment WHERE Id = :fileId];
        resultHTML = tempAttachment.Body.toString();
        parentFileId = tempAttachment.ParentId;
        
    }
    
    public void deleteParentFile(){
        Delete [select id from ASI_MFM_Mass_Upload_Log__c where Id = :parentFileId];
    }
    
    private static String formatDate(date d){
        if(d == null) return ''; 
        Datetime dt = d;
        return dt.format('yyyy-MM-dd');
    }
    
}