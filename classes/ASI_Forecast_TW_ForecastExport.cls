public class ASI_Forecast_TW_ForecastExport {
    public String datePeriod {get;set;}
    public transient String docType {get;set;}
    public transient List<ItemCsvWrapper> csvItemList {get; private set;}
    public transient String csvTitle {get; private set;}
    public transient String period {get; private set;}
    public transient String periodno {get; private set;}
    
    public ASI_Forecast_TW_ForecastExport(){
    }
    
	private List<AggregateResult> requestForecastData(Date startPeriod, Boolean isForecast){
        String fType = (isForecast) ? 'Forecast':'Budget';
        Date endPeriod = startPeriod.addMonths(1);
        Date startOfMonth = startPeriod.toStartOfMonth();
        Date startOfNextMonth= endPeriod.toStartOfMonth();
        return [SELECT ASI_Forecast_Item_Group__c
                ,SUM(ASI_Forecast_P1__c),SUM(ASI_Forecast_P2__c),SUM(ASI_Forecast_P3__c),SUM(ASI_Forecast_P4__c),SUM(ASI_Forecast_P5__c),SUM(ASI_Forecast_P6__c),SUM(ASI_Forecast_P7__c),SUM(ASI_Forecast_P8__c),SUM(ASI_Forecast_P9__c),SUM(ASI_Forecast_P10__c),SUM(ASI_Forecast_P11__c),SUM(ASI_Forecast_P12__c)
                FROM ASI_Forecast_Item__c
                WHERE ASI_Forecast_Period_Date__c >= :startOfMonth
                AND ASI_Forecast_Period_Date__c < :startOfNextMonth
                AND ASI_Forecast__r.ASI_Forecast_Type__c = :fType
                AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW_Item'
                GROUP BY ASI_Forecast_Item_Group__c,ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Code__c, ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Description__c
                ORDER BY ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Code__c
               ];
    }
    
    private Map<id,ASI_MFM_Item_Group__c> requestItemGroupDetail(Set<Id>itemgroupIdSet) {
        return new Map<id,ASI_MFM_Item_Group__c>([SELECT Id,ASI_CRM_Size_ml__c,ASI_CRM_CN_pack__c,ASI_MFM_Item_Group_Code__c,ASI_MFM_Item_Group_Description__c
                                                       FROM ASI_MFM_Item_Group__c
                                                       WHERE Id IN :itemgroupIdSet]);
    }
    
	public pageReference fetchList()
    {
        datePeriod 	= apexpages.currentPage().getParameters().get('dateperiod');
        docType 	= apexpages.currentPage().getParameters().get('type');
        
        List<String> months = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'};
        List<String> parts = datePeriod.split('-');
        Date startPeriod = Date.newInstance(integer.valueof(parts.get(0)), integer.valueof(parts.get(1)), 1);
        
        String periodStr = startPeriod.year()+'';
        if(startPeriod.month()<10) periodStr += '0';
        periodStr += startPeriod.month();
        periodno = periodStr;
        period   = startPeriod.year()+'-'+startPeriod.month();
		
        String result = '';
        for(integer i=0; i<12; i++){
            Integer index = Math.mod(startPeriod.month()+i-1, 12);
            String monthtx = months.get(index);
            result+=monthtx+',';
        }
        csvTitle = result.removeEnd(',');
        
        List<AggregateResult> arList;
        if(docType == 'Forecast') {
            arList = requestForecastData(startPeriod,true);
        } else if(docType == 'Budget') {
            arList = requestForecastData(startPeriod,false);
        }
        Set<Id> itemgroupIdSet = new Set<Id>();
        for(AggregateResult ar:arList){
            itemgroupIdSet.add((ID)ar.get('ASI_Forecast_Item_Group__c'));
        }
        Map<id,ASI_MFM_Item_Group__c> itemgroupMap = requestItemGroupDetail(itemgroupIdSet);
        system.debug(JSON.serialize(itemgroupMap));
        
        csvItemList = new List<ItemCsvWrapper>();
        for(AggregateResult ar:arList){
			Id itemgroupId = (ID)ar.get('ASI_Forecast_Item_Group__c');
            ASI_MFM_Item_Group__c itemGroup = itemgroupMap.get(itemgroupId);
            //system.debug('itemgroup : ' + JSON.serialize(itemGroup));
            if(itemGroup==null) continue;
            //ASI_CRM_Size_ml__c,ASI_CRM_CN_pack__c,ASI_MFM_Item_Group_Code__c,ASI_MFM_Item_Group_Description__c
            ItemCsvWrapper item = new ItemCsvWrapper();
			item.skucode = itemGroup.ASI_MFM_Item_Group_Code__c;
            item.skudesc = itemGroup.ASI_MFM_Item_Group_Description__c;
            if(itemGroup.ASI_CRM_CN_pack__c==null||itemGroup.ASI_CRM_Size_ml__c==null) {
                item.p1=item.p2=item.p3=item.p4=item.p5=item.p6=item.p7=item.p8=item.p9=item.p10=item.p11=item.p12=0;
                csvItemList.add(item);
                continue;
            } else {
                Double rate = Double.valueOf(itemGroup.ASI_CRM_Size_ml__c)/1000*Double.valueOf(itemGroup.ASI_CRM_CN_pack__c);
                Double unit = 9.0;
                Double p1 = (Double)ar.get('expr0');
                Double p2 = (Double)ar.get('expr1');
                Double p3 = (Double)ar.get('expr2');
                Double p4 = (Double)ar.get('expr3');
                Double p5 = (Double)ar.get('expr4');
                Double p6 = (Double)ar.get('expr5');
                Double p7 = (Double)ar.get('expr6');
                Double p8 = (Double)ar.get('expr7');
                Double p9 = (Double)ar.get('expr8');
                Double p10 = (Double)ar.get('expr9');
                Double p11 = (Double)ar.get('expr10');
                Double p12 = (Double)ar.get('expr11');
                
                system.debug('rate: ' + rate + ' code: ' + item.skucode + ' p5: '+p5);

                item.p1 = (p1!=null) ? Math.ceil(Double.valueOf(p1*unit/rate)):0;
                item.p2 = (p2!=null) ? Math.ceil(Double.valueOf(p2*unit/rate)):0;
                item.p3 = (p3!=null) ? Math.ceil(Double.valueOf(p3*unit/rate)):0;
                item.p4 = (p4!=null) ? Math.ceil(Double.valueOf(p4*unit/rate)):0;
                item.p5 = (p5!=null) ? Math.ceil(Double.valueOf(p5*unit/rate)):0;
                item.p6 = (p6!=null) ? Math.ceil(Double.valueOf(p6*unit/rate)):0;
                item.p7 = (p7!=null) ? Math.ceil(Double.valueOf(p7*unit/rate)):0;
                item.p8 = (p8!=null) ? Math.ceil(Double.valueOf(p8*unit/rate)):0;
                item.p9 = (p9!=null) ? Math.ceil(Double.valueOf(p9*unit/rate)):0;
                item.p10 = (p10!=null) ? Math.ceil(Double.valueOf(p10*unit/rate)):0;
                item.p11 = (p11!=null) ? Math.ceil(Double.valueOf(p11*unit/rate)):0;
                item.p12 = (p12!=null) ? Math.ceil(Double.valueOf(p12*unit/rate)):0;
                csvItemList.add(item);
            }
        }
        
        /*
        Map<Id,ItemCsvWrapper> itemMap = new Map<Id,ItemCsvWrapper>();
        List<ASI_Forecast_Item__c> itemList = new List<ASI_Forecast_Item__c>();
        if(docType == 'Forecast') {
            requestForecastData(startPeriod, startPeriod.addMonths(1),true);
            itemList = ASI_CRM_TW_Forecast_Util.searchForecastForReport(startPeriod, startPeriod.addMonths(1));
        } else if(docType == 'Budget') {
            itemList = ASI_CRM_TW_Forecast_Util.searchBudgetForReport(startPeriod, startPeriod.addMonths(1));
        }
        for(ASI_Forecast_Item__c item : itemList) {
            Id itemGroupId = item.ASI_Forecast_Item_Group__c;
            if(itemMap.get(itemGroupId)==null) {
                itemMap.put(itemGroupId, new ItemCsvWrapper(item));
            } else {
                itemMap.get(itemGroupId).itemPeriodAdd(item);
            }
        }
        csvItemList = new List<ItemCsvWrapper>();
        for (Id key : itemMap.keySet()) {
            ItemCsvWrapper item = itemMap.get(key);
            item.p1 = Math.ceil(item.p1);
            item.p2 = Math.ceil(item.p2);
            item.p3 = Math.ceil(item.p3);
            item.p4 = Math.ceil(item.p4);
            item.p5 = Math.ceil(item.p5);
            item.p6 = Math.ceil(item.p6);
            item.p7 = Math.ceil(item.p7);
            item.p8 = Math.ceil(item.p8);
            item.p9 = Math.ceil(item.p9);
            item.p10 = Math.ceil(item.p10);
            item.p11 = Math.ceil(item.p11);
            item.p12 = Math.ceil(item.p12);
            csvItemList.add(item);
        }
*/
        return null;
    }
    
    public class ItemCsvWrapper {
        public String skucode {get; set;}
        public String skudesc {get; set;}
        public Double p1 {get; set;}
		public Double p2 {get; set;}
		public Double p3 {get; set;}
		public Double p4 {get; set;}
		public Double p5 {get; set;}
		public Double p6 {get; set;}
		public Double p7 {get; set;}
		public Double p8 {get; set;}
		public Double p9 {get; set;}
		public Double p10 {get; set;}
		public Double p11 {get; set;}
		public Double p12 {get; set;}
        
        public ItemCsvWrapper(){}

        public void itemPeriodAdd(ASI_Forecast_Item__c item){
            if(item.ASI_Forecast_Item_Pack__c==null||item.ASI_Forecast_Item_Size__c==null) {
                system.debug('invaild pack or size value: ' + item.ASI_Forecast_Item_Group__c);
                return;
            }
			Double rate = Double.valueOf(item.ASI_Forecast_Item_Size__c)/1000*Double.valueOf(item.ASI_Forecast_Item_Pack__c);
            Double unit = 9.0;
            this.p1 += (item.ASI_Forecast_P1__c!=null) ? Double.valueOf(item.ASI_Forecast_P1__c*unit/rate):0;
            this.p2 += (item.ASI_Forecast_P2__c!=null) ? Double.valueOf(item.ASI_Forecast_P2__c*unit/rate):0;
            this.p3 += (item.ASI_Forecast_P3__c!=null) ? Double.valueOf(item.ASI_Forecast_P3__c*unit/rate):0;
            this.p4 += (item.ASI_Forecast_P4__c!=null) ? Double.valueOf(item.ASI_Forecast_P4__c*unit/rate):0;
            this.p5 += (item.ASI_Forecast_P5__c!=null) ? Double.valueOf(item.ASI_Forecast_P5__c*unit/rate):0;
            this.p6 += (item.ASI_Forecast_P6__c!=null) ? Double.valueOf(item.ASI_Forecast_P6__c*unit/rate):0;
            this.p7 += (item.ASI_Forecast_P7__c!=null) ? Double.valueOf(item.ASI_Forecast_P7__c*unit/rate):0;
            this.p8 += (item.ASI_Forecast_P8__c!=null) ? Double.valueOf(item.ASI_Forecast_P8__c*unit/rate):0;
            this.p9 += (item.ASI_Forecast_P9__c!=null) ? Double.valueOf(item.ASI_Forecast_P9__c*unit/rate):0;
            this.p10 += (item.ASI_Forecast_P10__c!=null) ? Double.valueOf(item.ASI_Forecast_P10__c*unit/rate):0;
            this.p11 += (item.ASI_Forecast_P11__c!=null) ? Double.valueOf(item.ASI_Forecast_P11__c*unit/rate):0;
            this.p12 += (item.ASI_Forecast_P12__c!=null) ? Double.valueOf(item.ASI_Forecast_P12__c*unit/rate):0;
        }


        public ItemCsvWrapper(ASI_Forecast_Item__c item) {
            this.skucode	= item.ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Code__c;
            this.skudesc	= item.ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Description__c;
            if(item.ASI_Forecast_Item_Pack__c==null||item.ASI_Forecast_Item_Size__c==null) {
                this.p1=this.p2=this.p3=this.p4=this.p5=this.p6=this.p7=this.p8=this.p9=this.p10=this.p11=this.p12=0;
                return;
            }
			Double rate = Double.valueOf(item.ASI_Forecast_Item_Size__c)/1000*Double.valueOf(item.ASI_Forecast_Item_Pack__c);
            Double unit = 9.0;
            this.p1 = (item.ASI_Forecast_P1__c!=null) ? Double.valueOf(item.ASI_Forecast_P1__c*unit/rate):0;
            this.p2 = (item.ASI_Forecast_P2__c!=null) ? Double.valueOf(item.ASI_Forecast_P2__c*unit/rate):0;
            this.p3 = (item.ASI_Forecast_P3__c!=null) ? Double.valueOf(item.ASI_Forecast_P3__c*unit/rate):0;
            this.p4 = (item.ASI_Forecast_P4__c!=null) ? Double.valueOf(item.ASI_Forecast_P4__c*unit/rate):0;
            this.p5 = (item.ASI_Forecast_P5__c!=null) ? Double.valueOf(item.ASI_Forecast_P5__c*unit/rate):0;
            this.p6 = (item.ASI_Forecast_P6__c!=null) ? Double.valueOf(item.ASI_Forecast_P6__c*unit/rate):0;
            this.p7 = (item.ASI_Forecast_P7__c!=null) ? Double.valueOf(item.ASI_Forecast_P7__c*unit/rate):0;
            this.p8 = (item.ASI_Forecast_P8__c!=null) ? Double.valueOf(item.ASI_Forecast_P8__c*unit/rate):0;
            this.p9 = (item.ASI_Forecast_P9__c!=null) ? Double.valueOf(item.ASI_Forecast_P9__c*unit/rate):0;
            this.p10 = (item.ASI_Forecast_P10__c!=null) ? Double.valueOf(item.ASI_Forecast_P10__c*unit/rate):0;
            this.p11 = (item.ASI_Forecast_P11__c!=null) ? Double.valueOf(item.ASI_Forecast_P11__c*unit/rate):0;
            this.p12 = (item.ASI_Forecast_P12__c!=null) ? Double.valueOf(item.ASI_Forecast_P12__c*unit/rate):0;
        }
    }

}