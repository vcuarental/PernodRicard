public class ASI_CN_NPL_ForecastController {
    public ID nplId { get; private set; }
    public ASI_CN_NPL_NPL_Request__c nplHeader { get; set; }
    public Boolean hasError { get; private set; }
    public Boolean isEditable { get; private set; }
    
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_South {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_East {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_Central {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_North {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_NorthWest {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_SouthWest {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_Macau {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_Mongolia {get; set; }
    
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_STK3 {
        get {
                List<ASI_CN_NPL_NPL_Forecast__c> stk3List = [select id, ASI_CN_NPL_Type__c, ASI_CN_NPL_Region__c, ASI_CN_NPL_M6__c, ASI_CN_NPL_M5__c, ASI_CN_NPL_M4__c, ASI_CN_NPL_M3__c, ASI_CN_NPL_M2__c, ASI_CN_NPL_M1__c from ASI_CN_NPL_NPL_Forecast__c where New_Product_Launch_Request__c = :nplId and ASI_CN_NPL_Type__c = 'Sales Volume' and ASI_CN_NPL_Region__c = 'STK3'];
                    
                if (stk3List.size() == 0){
                    ASI_CN_NPL_NPL_Forecast__c forecast = new ASI_CN_NPL_NPL_Forecast__c(New_Product_Launch_Request__c = nplId, ASI_CN_NPL_Type__c = 'Sales Volume', ASI_CN_NPL_Region__c = 'STK3');
                    insert forecast;
                    
                    SalesVolForecast_STK3 = forecast;
                    return SalesVolForecast_STK3;
                }
                else {
                    return SalesVolForecast_STK3;
                }
            } 
        set {
            SalesVolForecast_STK3 = value;
        } 
    }
    
    public ASI_CN_NPL_NPL_Forecast__c SalesVolForecast_HQ {
        get {
                List<ASI_CN_NPL_NPL_Forecast__c> hqList = [select id, ASI_CN_NPL_Type__c, ASI_CN_NPL_Region__c, ASI_CN_NPL_M6__c, ASI_CN_NPL_M5__c, ASI_CN_NPL_M4__c, ASI_CN_NPL_M3__c, ASI_CN_NPL_M2__c, ASI_CN_NPL_M1__c from ASI_CN_NPL_NPL_Forecast__c where New_Product_Launch_Request__c = :nplId and ASI_CN_NPL_Type__c = 'Sales Volume' and ASI_CN_NPL_Region__c = 'HQ'];
                    
                if (hqList.size() == 0){
                    ASI_CN_NPL_NPL_Forecast__c forecast = new ASI_CN_NPL_NPL_Forecast__c(New_Product_Launch_Request__c = nplId, ASI_CN_NPL_Type__c = 'Sales Volume', ASI_CN_NPL_Region__c = 'HQ');
                    insert forecast;
                    
                    SalesVolForecast_HQ = forecast;
                    return SalesVolForecast_HQ;
                }
                else {
                    return SalesVolForecast_HQ;
                }
            } 
        set {
            SalesVolForecast_HQ = value;
        } 
    }
    
    public ASI_CN_NPL_NPL_Forecast__c OldStockInvForecast_South {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockInvForecast_East {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockInvForecast_Central {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockInvForecast_North {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockInvForecast_NorthWest {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockInvForecast_SouthWest {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockInvForecast_Macau {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockInvForecast_Mongolia {get; set; }
    
    public ASI_CN_NPL_NPL_Forecast__c OldStockDepletForecast_South {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockDepletForecast_East {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockDepletForecast_Central {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockDepletForecast_North {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockDepletForecast_NorthWest {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockDepletForecast_SouthWest {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockDepletForecast_Macau {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c OldStockDepletForecast_Mongolia {get; set; }

    public ASI_CN_NPL_NPL_Forecast__c MonitoringForecast_South {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c MonitoringForecast_East {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c MonitoringForecast_Central {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c MonitoringForecast_North {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c MonitoringForecast_NorthWest {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c MonitoringForecast_SouthWest {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c MonitoringForecast_Macau {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c MonitoringForecast_Mongolia {get; set; }
    public ASI_CN_NPL_NPL_Forecast__c MonitoringForecast_HQ {get; set; }
    
    //Domestic Launch Date
    public String SalesVolDomM1 {get; private set;}
    public String SalesVolDomM2 {get; private set;}
    public String SalesVolDomM3 {get; private set;}
    public String SalesVolDomM4 {get; private set;}
    public String SalesVolDomM5 {get; private set;}
    public String SalesVolDomM6 {get; private set;}
    
    //20151222 Ben @ Elufa System
    public String HQSalesVolM1 {get; private set;}
    public String HQSalesVolM2 {get; private set;}
    public String HQSalesVolM3 {get; private set;}
    public String HQSalesVolM4 {get; private set;}
    public String HQSalesVolM5 {get; private set;}
    public String HQSalesVolM6 {get; private set;}
    //20151222 End
    
    //20151221 Ben @ Elufa System Actual Delpetion Month Start
    /*public String southActualDepletionMonth1 {get; private set;}
    public String southActualDepletionMonth2 {get; private set;}
    public String southActualDepletionMonth3 {get; private set;}
    public String southActualDepletionMonth4 {get; private set;}
    public String southActualDepletionMonth5 {get; private set;}
    public String southActualDepletionMonth6 {get; private set;}
    
    public String eastActualDepletionMonth1 {get; private set;}
    public String eastActualDepletionMonth2 {get; private set;}
    public String eastActualDepletionMonth3 {get; private set;}
    public String eastActualDepletionMonth4 {get; private set;}
    public String eastActualDepletionMonth5 {get; private set;}
    public String eastActualDepletionMonth6 {get; private set;}
    
    public String centralActualDepletionMonth1 {get; private set;}
    public String centralActualDepletionMonth2 {get; private set;}
    public String centralActualDepletionMonth3 {get; private set;}
    public String centralActualDepletionMonth4 {get; private set;}
    public String centralActualDepletionMonth5 {get; private set;}
    public String centralActualDepletionMonth6 {get; private set;}
    
    public String northActualDepletionMonth1 {get; private set;}
    public String northActualDepletionMonth2 {get; private set;}
    public String northActualDepletionMonth3 {get; private set;}
    public String northActualDepletionMonth4 {get; private set;}
    public String northActualDepletionMonth5 {get; private set;}
    public String northActualDepletionMonth6 {get; private set;}
    
    public String northWestActualDepletionMonth1 {get; private set;}
    public String northWestActualDepletionMonth2 {get; private set;}
    public String northWestActualDepletionMonth3 {get; private set;}
    public String northWestActualDepletionMonth4 {get; private set;}
    public String northWestActualDepletionMonth5 {get; private set;}
    public String northWestActualDepletionMonth6 {get; private set;}
    
    public String southWestActualDepletionMonth1 {get; private set;}
    public String southWestActualDepletionMonth2 {get; private set;}
    public String southWestActualDepletionMonth3 {get; private set;}
    public String southWestActualDepletionMonth4 {get; private set;}
    public String southWestActualDepletionMonth5 {get; private set;}
    public String southWestActualDepletionMonth6 {get; private set;}*/
    
    public String HQActualDepletionMonth1 {get; private set;}
    public String HQActualDepletionMonth2 {get; private set;}
    public String HQActualDepletionMonth3 {get; private set;}
    public String HQActualDepletionMonth4 {get; private set;}
    public String HQActualDepletionMonth5 {get; private set;}
    public String HQActualDepletionMonth6 {get; private set;}
    
    public String domestucActualDepletionMonth1 {get; private set;}
    public String domestucActualDepletionMonth2 {get; private set;}
    public String domestucActualDepletionMonth3 {get; private set;}
    public String domestucActualDepletionMonth4 {get; private set;}
    public String domestucActualDepletionMonth5 {get; private set;}
    public String domestucActualDepletionMonth6 {get; private set;}
    
    public String macauMongoliaActualDepletionMonth1 {get; private set;}
    public String macauMongoliaActualDepletionMonth2 {get; private set;}
    public String macauMongoliaActualDepletionMonth3 {get; private set;}
    public String macauMongoliaActualDepletionMonth4 {get; private set;}
    public String macauMongoliaActualDepletionMonth5 {get; private set;}
    public String macauMongoliaActualDepletionMonth6 {get; private set;}
    
    /*public String macauActualDepletionMonth1 {get; private set;}
    public String macauActualDepletionMonth2 {get; private set;}
    public String macauActualDepletionMonth3 {get; private set;}
    public String macauActualDepletionMonth4 {get; private set;}
    public String macauActualDepletionMonth5 {get; private set;}
    public String macauActualDepletionMonth6 {get; private set;}
    
    public String mongoliaActualDepletionMonth1 {get; private set;}
    public String mongoliaActualDepletionMonth2 {get; private set;}
    public String mongoliaActualDepletionMonth3 {get; private set;}
    public String mongoliaActualDepletionMonth4 {get; private set;}
    public String mongoliaActualDepletionMonth5 {get; private set;}
    public String mongoliaActualDepletionMonth6 {get; private set;}*/
    
    //20151221 End
    
    //Macau Launch Date
    public String SalesVolMMM1 {get; private set;}
    public String SalesVolMMM2 {get; private set;}
    public String SalesVolMMM3 {get; private set;}
    public String SalesVolMMM4 {get; private set;}
    public String SalesVolMMM5 {get; private set;}
    public String SalesVolMMM6 {get; private set;}
    
    //Mongolia Launch Date
    public String SalesVolMongo1 {get; private set;}
    public String SalesVolMongo2 {get; private set;}
    public String SalesVolMongo3 {get; private set;}
    public String SalesVolMongo4 {get; private set;}
    public String SalesVolMongo5 {get; private set;}
    public String SalesVolMongo6 {get; private set;}
    
    public String CreateDateM1 {get; private set;}
    public String CreateDateM2 {get; private set;}
    public String CreateDateM3 {get; private set;}
    public String CreateDateM4 {get; private set;}
    public String CreateDateM5 {get; private set;}
    public String CreateDateM6 {get; private set;}
    
    public Decimal SalesVolM1Total {get; set;}
    public Decimal SalesVolM2Total {get; set;}
    public Decimal SalesVolM3Total {get; set;}
    public Decimal SalesVolM4Total {get; set;}
    public Decimal SalesVolM5Total {get; set;}
    public Decimal SalesVolM6Total {get; set;}

    public Decimal SalesVolM1DomSubTotal {get; set;}
    public Decimal SalesVolM2DomSubTotal {get; set;}
    public Decimal SalesVolM3DomSubTotal {get; set;}
    public Decimal SalesVolM4DomSubTotal {get; set;}
    public Decimal SalesVolM5DomSubTotal {get; set;}
    public Decimal SalesVolM6DomSubTotal {get; set;}
    
    public Decimal SalesVolM1MMSubTotal {get; set;}
    public Decimal SalesVolM2MMSubTotal {get; set;}
    public Decimal SalesVolM3MMSubTotal {get; set;}
    public Decimal SalesVolM4MMSubTotal {get; set;}
    public Decimal SalesVolM5MMSubTotal {get; set;}
    public Decimal SalesVolM6MMSubTotal {get; set;}
    
    public Decimal SalesVolM1STK3DomSubTotal {get; set;}
    public Decimal SalesVolM2STK3DomSubTotal {get; set;}
    public Decimal SalesVolM3STK3DomSubTotal {get; set;}
    public Decimal SalesVolM4STK3DomSubTotal {get; set;}
    public Decimal SalesVolM5STK3DomSubTotal {get; set;}
    public Decimal SalesVolM6STK3DomSubTotal {get; set;}
    
    public Decimal MonitorM1DomSubTotal {get; set;}
    public Decimal MonitorM2DomSubTotal {get; set;}
    public Decimal MonitorM3DomSubTotal {get; set;}
    public Decimal MonitorM4DomSubTotal {get; set;}
    public Decimal MonitorM5DomSubTotal {get; set;}
    public Decimal MonitorM6DomSubTotal {get; set;}
    
    public Decimal MonitorM1MMSubTotal {get; set;}
    public Decimal MonitorM2MMSubTotal {get; set;}
    public Decimal MonitorM3MMSubTotal {get; set;}
    public Decimal MonitorM4MMSubTotal {get; set;}
    public Decimal MonitorM5MMSubTotal {get; set;}
    public Decimal MonitorM6MMSubTotal {get; set;}
    
    public Decimal VarM1DomSubTotal {get; set;}
    public Decimal VarM2DomSubTotal {get; set;}
    public Decimal VarM3DomSubTotal {get; set;}
    public Decimal VarM4DomSubTotal {get; set;}
    public Decimal VarM5DomSubTotal {get; set;}
    public Decimal VarM6DomSubTotal {get; set;}
    
    public Decimal VarM1MMSubTotal {get; set;}
    public Decimal VarM2MMSubTotal {get; set;}
    public Decimal VarM3MMSubTotal {get; set;}
    public Decimal VarM4MMSubTotal {get; set;}
    public Decimal VarM5MMSubTotal {get; set;}
    public Decimal VarM6MMSubTotal {get; set;}
    
    public Decimal OldStockInvM1Total {get; set;}
    public Decimal OldStockInvM2Total {get; set;}
    public Decimal OldStockInvM3Total {get; set;}
    public Decimal OldStockInvM4Total {get; set;}
    public Decimal OldStockInvM5Total {get; set;}
    public Decimal OldStockInvM6Total {get; set;}

    public Decimal OldStockDepletM1Total {get; set;}
    public Decimal OldStockDepletM2Total {get; set;}
    public Decimal OldStockDepletM3Total {get; set;}
    public Decimal OldStockDepletM4Total {get; set;}
    public Decimal OldStockDepletM5Total {get; set;}
    public Decimal OldStockDepletM6Total {get; set;}
    
    public Map<String, Decimal> MonitorVarSouth {get; set;}
    public Map<String, Decimal> MonitorVarEast {get; set;}
    public Map<String, Decimal> MonitorVarCentral {get; set;}
    public Map<String, Decimal> MonitorVarNorth {get; set;}
    public Map<String, Decimal> MonitorVarNorthWest {get; set;}
    public Map<String, Decimal> MonitorVarSouthWest {get; set;}
    public Map<String, Decimal> MonitorVarMacau {get; set;}
    public Map<String, Decimal> MonitorVarMongolia {get; set;}
    //20151222 Ben @ Elufa System
    public Map<String, Decimal> MonitorVarHQ {get; set;}

    public map<string, ASI_CRM_CN_Channel__c> map_channels {get; set;} //20190111 Vincent Lam
    public map<string, map<string, ASI_CN_NPL_NPL_Forecast__c>> map_channel_region_forecast {get;set;} //20190111 Vincent Lam
    public map<string, map<string, decimal>> map_channel_subTotal {get;set;} //20190111 Vincent Lam
    public map<string, map<string, decimal>> map_region_subTotal {get;set;} //20190111 Vincent Lam
    public map<string, decimal> map_grandTotal {get;set;} //20190111 Vincent Lam
    public list<string> list_regions {get; set;} //20190111 Vincent Lam
    
    public ASI_CN_NPL_ForecastController(ApexPages.StandardController stdController) {
        this.nplId = stdController.getId();
        List<ASI_CN_NPL_NPL_Request__c> tempNPLHeaders = [SELECT Id, Name, ASI_CN_NPL_Supply_Plan_M6__c, ASI_CN_NPL_Supply_Plan_M5__c, ASI_CN_NPL_Supply_Plan_M4__c, ASI_CN_NPL_Supply_Plan_M3__c, ASI_CN_NPL_Supply_Plan_M2__c, 
            ASI_CN_NPL_Supply_Plan_M1__c, ASI_CN_NPL_Size_Carton__c, ASI_CN_NPL_Size_Box__c, ASI_CN_NPL_Size_Bottle__c, ASI_CN_NPL_Request_ETA__c, ASI_CN_NPL_PO_Released_Date__c, ASI_CN_NPL_Invoice_Receipt_Date__c, ASI_CN_NPL_Gross_Weight__c, 
                ASI_CN_NPL_Estimate_Available_Date__c, ASI_CN_NPL_English_Name_Proposal__c, ASI_CN_NPL_English_Name_Final__c, ASI_CN_NPL_ETA_Packing__c, ASI_CN_NPL_Chinese_Name_Proposal__c, ASI_CN_NPL_Chinese_Name_Final__c, ASI_CN_NPL_Cert_Available_Date__c, 
                    ASI_CN_NPL_Bar_Code_Carton__c, ASI_CN_NPL_Bar_Code_Box__c, ASI_CN_NPL_Bar_Code_Bottle__c, ASI_CN_NPL_Available_Date__c, ASI_CN_NPL_Artwork_Finalize_Date__c, ASI_CN_NPL_Artwork_Brand_Owner_Date__c, ASI_CN_NPL_Actual_ETA__c, 
                        ASI_CN_NPL_Domestic_Launch_Date__c, ASI_CN_NPL_MM_Launch_Date__c, ASI_CN_NPL_When_to_Launch__c, ASI_CN_NPL_Date__c, ASI_CN_NPL_Supply_Plan_MM_M6__c, ASI_CN_NPL_Supply_Plan_MM_M5__c, ASI_CN_NPL_Supply_Plan_MM_M4__c, ASI_CN_NPL_Supply_Plan_MM_M3__c, ASI_CN_NPL_Supply_Plan_MM_M2__c, 
                            ASI_CN_NPL_Supply_Plan_MM_M1__c, ASI_CN_NPL_Request_ETA_MM__c, ASI_CN_NPL_PO_Released_Date_MM__c, ASI_CN_NPL_Invoice_Receipt_Date_MM__c, ASI_CN_NPL_Available_Date_MM__c, ASI_CN_NPL_Actual_ETA_MM__c, ASI_CN_NPL_Destination_M_M__c, ASI_CN_NPL_Destination_Domestic__c,
                                ASI_CN_NPL_Sales_Vol_Forecast_Picture__c, ASI_CN_NPL_Old_Stock_Start_Date__c , ASI_CN_NPL_SupplyPlan_Dom_StartDate__c, ASI_CN_NPL_SupplyPlan_MM_StartDate__c, ASI_NPL_HQ_Available_Date__c, ASI_NPL_HQ_Actual_ETA__c,
                                    ASI_NPL_HQ_Invoice_Receipt_Date__c, ASI_NPL_HQ_Estimate_Available_Date__c, ASI_NPL_HQ_Request_ETA__c, ASI_NPL_HQ_PO_Released_Date__c, ASI_NPL_HQ_Supply_Plan_M6__c, ASI_NPL_HQ_Supply_Plan_M5__c, ASI_NPL_HQ_Supply_Plan_M4__c,
                                        ASI_NPL_HQ_Supply_Plan_M3__c, ASI_NPL_HQ_Supply_Plan_M2__c, ASI_NPL_HQ_Supply_Plan_M1__c, ASI_NPL_HQ_Destination__c, ASI_NPL_HQ_SupplyPlan_Dom_StartDate__c, 
                                            ASI_CN_NPL_HQActualDelpetionMonth__c, ASI_CN_NPL_Domestic_ActualDepletionMonth__c, ASI_CN_NPL_MacMongo_ActualDepletionMonth__c, ASI_CN_NPL_HQ_Launch_Date__c,//20151218 Ben @ Elufa System add HQ Field
                                                ASI_NPL_ETA__c, ASI_NPL_TP_Per_Case__c, ASI_NPL_ETA_Domestic__c, ASI_NPL_TP_Per_Case_Domestic__c, ASI_CN_NPL_Status__c//20170815 Introv
                                                FROM ASI_CN_NPL_NPL_Request__c WHERE Id = :nplId];    
                        
        if (tempNPLHeaders.size() > 0){      
            this.nplHeader = tempNPLHeaders.get(0);    
            this.hasError = false;
            initPage();
            initAccess();
        }

        //20190111 Alan Lau START
        map_channel_region_forecast = new map<string, map<string, ASI_CN_NPL_NPL_Forecast__c>>();
        map_channel_subTotal = new map<string, map<string, decimal>>();
        map_region_subTotal = new map<string, map<string, decimal>>();
        map_grandTotal = new map<string, decimal>{
            'M1' => 0,
            'M2' => 0,
            'M3' => 0,
            'M4' => 0,
            'M5' => 0,
            'M6' => 0,
            'M7' => 0,
            'Grand' => 0
        };
        map_channels = new map<string, ASI_CRM_CN_Channel__c>();
        set<string> set_regions = new set<string>();
        List<ASI_CRM_CN_Channel__c> list_Channel = [
                SELECT Id,
                        Name,
                        ASI_CRM_CN_Channel_Group__r.Name,
                        ASI_NPL_Region__c
                FROM ASI_CRM_CN_Channel__c
                WHERE RecordType.DeveloperName = 'ASI_NPL_CN_Request_Forecast_Channel'
                //AND ASI_CRM_CN_Channel_Group__r.RecordType.DeveloperName = 'ASI_NPL_CN_Channel_Group'
                AND ASI_NPL_Region__c != NULL
                ORDER BY ASI_CRM_CN_Sequence__c
        ];
        for (ASI_CRM_CN_Channel__c channel : list_Channel) {
            map_channels.put(channel.id, channel);
            map<string, ASI_CN_NPL_NPL_Forecast__c> map_region_forecast = map_channel_region_forecast.containsKey(channel.Id) ? map_channel_region_forecast.get(channel.Id) : new map<string, ASI_CN_NPL_NPL_Forecast__c>();
            map<string, decimal> map_subTotal = map_channel_subTotal.containsKey(channel.Id) ? map_channel_subTotal.get(channel.Id) : new map<string, decimal>();
            for (string region : channel.ASI_NPL_Region__c.split(';')) {
                map_region_forecast.put(region,
                        new ASI_CN_NPL_NPL_Forecast__c(
                                New_Product_Launch_Request__c = this.nplId,
                                ASI_CN_NPL_Type__c = 'Sales Volume',
                                ASI_CN_NPL_Region__c = region,
                                ASI_NPL_Channel__c = channel.Id,
                                ASI_CN_NPL_M1__c = 0,
                                ASI_CN_NPL_M2__c = 0,
                                ASI_CN_NPL_M3__c = 0,
                                ASI_CN_NPL_M4__c = 0,
                                ASI_CN_NPL_M5__c = 0,
                                ASI_CN_NPL_M6__c = 0
                        )
                );
                map_subTotal.put(region,0);
                set_regions.add(region);
                
                if(!map_region_subTotal.containsKey(region)){
                    map<string, decimal> map_region = new map<string, decimal>();
                    map_region.put('M1',0);
                    map_region.put('M2',0);
                    map_region.put('M3',0);
                    map_region.put('M4',0);
                    map_region.put('M5',0);
                    map_region.put('M6',0);
                    map_region.put('Grand',0);
                    map_region_subTotal.put(region, map_region);
                }
            }
            map_subTotal.put('M1',0);
            map_subTotal.put('M2',0);
            map_subTotal.put('M3',0);
            map_subTotal.put('M4',0);
            map_subTotal.put('M5',0);
            map_subTotal.put('M6',0);
            map_subTotal.put('Grand',0);
            map_channel_region_forecast.put(channel.Id, map_region_forecast);
            map_channel_subTotal.put(channel.Id, map_subTotal);
        }

        for(ASI_CN_NPL_NPL_Forecast__c f :  [
                SELECT Id,
                        ASI_CN_NPL_Region__c,
                        ASI_CN_NPL_M1__c,
                        ASI_CN_NPL_M2__c,
                        ASI_CN_NPL_M3__c,
                        ASI_CN_NPL_M4__c,
                        ASI_CN_NPL_M5__c,
                        ASI_CN_NPL_M6__c,
                        ASI_NPL_Channel__c
                FROM ASI_CN_NPL_NPL_Forecast__c
                WHERE New_Product_Launch_Request__c = :this.nplId
                AND ASI_NPL_Channel__c IN :map_channels.keySet()
        ]){
            decimal thisTotal = f.ASI_CN_NPL_M1__c + f.ASI_CN_NPL_M2__c + f.ASI_CN_NPL_M3__c + f.ASI_CN_NPL_M4__c + f.ASI_CN_NPL_M5__c + f.ASI_CN_NPL_M6__c;
            if(map_channel_region_forecast.containsKey(f.ASI_NPL_Channel__c)){
                map<string, ASI_CN_NPL_NPL_Forecast__c> map_region_forecast = map_channel_region_forecast.get(f.ASI_NPL_Channel__c);
                if(map_region_forecast.containsKey(f.ASI_CN_NPL_Region__c)){
                    map_region_forecast.put(f.ASI_CN_NPL_Region__c, f);
                    map_channel_region_forecast.put(f.ASI_NPL_Channel__c, map_region_forecast); //Alan Lau 20190128
                }
            }
            if(map_channel_subTotal.containsKey(f.ASI_NPL_Channel__c)){
                map<string, decimal> map_subTotal = map_channel_subTotal.get(f.ASI_NPL_Channel__c);
                if(map_subTotal.containsKey(f.ASI_CN_NPL_Region__c)){
                    decimal total = map_subTotal.get(f.ASI_CN_NPL_Region__c);
                    map_subTotal.put(f.ASI_CN_NPL_Region__c, total + thisTotal);
                }
                decimal totalM1 = map_subTotal.get('M1');
                map_subTotal.put('M1', totalM1 + f.ASI_CN_NPL_M1__c);
                decimal totalM2 = map_subTotal.get('M2');
                map_subTotal.put('M2', totalM2 + f.ASI_CN_NPL_M2__c);
                decimal totalM3 = map_subTotal.get('M3');
                map_subTotal.put('M3', totalM3 + f.ASI_CN_NPL_M3__c);
                decimal totalM4 = map_subTotal.get('M4');
                map_subTotal.put('M4', totalM4 + f.ASI_CN_NPL_M4__c);
                decimal totalM5 = map_subTotal.get('M5');
                map_subTotal.put('M5', totalM5 + f.ASI_CN_NPL_M5__c);
                decimal totalM6 = map_subTotal.get('M6');
                map_subTotal.put('M6', totalM6 + f.ASI_CN_NPL_M6__c);
                decimal totalGrand = map_subTotal.get('Grand');
                map_subTotal.put('Grand', totalGrand + thisTotal);
                map_channel_subTotal.put(f.ASI_NPL_Channel__c, map_subTotal); //Alan Lau 20190128
            }
            if(map_region_subTotal.containsKey(f.ASI_CN_NPL_Region__c)){
                map<string, decimal> map_subTotal = map_region_subTotal.get(f.ASI_CN_NPL_Region__c);
                decimal totalM1 = map_subTotal.get('M1');
                map_subTotal.put('M1', totalM1 + f.ASI_CN_NPL_M1__c);
                decimal totalM2 = map_subTotal.get('M2');
                map_subTotal.put('M2', totalM2 + f.ASI_CN_NPL_M2__c);
                decimal totalM3 = map_subTotal.get('M3');
                map_subTotal.put('M3', totalM3 + f.ASI_CN_NPL_M3__c);
                decimal totalM4 = map_subTotal.get('M4');
                map_subTotal.put('M4', totalM4 + f.ASI_CN_NPL_M4__c);
                decimal totalM5 = map_subTotal.get('M5');
                map_subTotal.put('M5', totalM5 + f.ASI_CN_NPL_M5__c);
                decimal totalM6 = map_subTotal.get('M6');
                map_subTotal.put('M6', totalM6 + f.ASI_CN_NPL_M6__c);
                decimal totalGrand = map_subTotal.get('Grand');
                map_subTotal.put('Grand', totalGrand + thisTotal);
                map_region_subTotal.put(f.ASI_CN_NPL_Region__c, map_subTotal); //Alan Lau 20190128
            }
            decimal totalGrandM1 = map_grandTotal.get('M1');
            map_grandTotal.put('M1', totalGrandM1 + f.ASI_CN_NPL_M1__c);
            decimal totalGrandM2 = map_grandTotal.get('M2');
            map_grandTotal.put('M2', totalGrandM2 + f.ASI_CN_NPL_M2__c);
            decimal totalGrandM3 = map_grandTotal.get('M3');
            map_grandTotal.put('M3', totalGrandM3 + f.ASI_CN_NPL_M3__c);
            decimal totalGrandM4 = map_grandTotal.get('M4');
            map_grandTotal.put('M4', totalGrandM4 + f.ASI_CN_NPL_M4__c);
            decimal totalGrandM5 = map_grandTotal.get('M5');
            map_grandTotal.put('M5', totalGrandM5 + f.ASI_CN_NPL_M5__c);
            decimal totalGrandM6 = map_grandTotal.get('M6');
            map_grandTotal.put('M6', totalGrandM6 + f.ASI_CN_NPL_M6__c);
            decimal totalGrand = map_grandTotal.get('Grand');
            map_grandTotal.put('Grand', totalGrand + thisTotal);
        }
        
        list_regions = new list<string>(set_regions);

        //20190111 Alan Lau END
    }
    
    public void initAccess(){
       List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :this.nplId];
        
        System.debug('listUserRecordAccess: ' + listUserRecordAccess);
        System.debug('listUserRecordAccess Size: ' + listUserRecordAccess.size());
       
        if (listUserRecordAccess.size() > 0){
            this.isEditable = listUserRecordAccess.get(0).HasEditAccess;
            System.debug('isEditable: ' + isEditable);        
        }
        
        System.debug(ApexPages.currentPage().getUrl());
        System.debug('is PDF Generation: ' + ApexPages.currentPage().getUrl().contains('RequestSavePDFPage'));
        
        //Set not editable for PDF generation in order to render outputField on PDF
        if (ApexPages.currentPage().getUrl().contains('RequestSavePDFPage')){
            this.isEditable = false;
            System.debug('PDF Generation, isEditable: ' + isEditable);          
        }

    }
    public PageReference cancel(){
        return new PageReference('/' + this.nplId); 
    }
    
    public PageReference saveForecasts(){       
        List<ASI_CN_NPL_NPL_Forecast__c> nplForecasts = new List<ASI_CN_NPL_NPL_Forecast__c>(); 
        
        //Add Forecast object into list for mass update
        nplForecasts.add(this.SalesVolForecast_South);
        nplForecasts.add(this.SalesVolForecast_East);
        nplForecasts.add(this.SalesVolForecast_Central);
        nplForecasts.add(this.SalesVolForecast_North);
        nplForecasts.add(this.SalesVolForecast_NorthWest);
        nplForecasts.add(this.SalesVolForecast_SouthWest);
        nplForecasts.add(this.SalesVolForecast_Macau);
        nplForecasts.add(this.SalesVolForecast_Mongolia);
        nplForecasts.add(this.SalesVolForecast_STK3);
        nplForecasts.add(this.SalesVolForecast_HQ);

        nplForecasts.add(this.OldStockInvForecast_South);
        nplForecasts.add(this.OldStockInvForecast_East);
        nplForecasts.add(this.OldStockInvForecast_Central);
        nplForecasts.add(this.OldStockInvForecast_North);
        nplForecasts.add(this.OldStockInvForecast_NorthWest);
        nplForecasts.add(this.OldStockInvForecast_SouthWest);
        nplForecasts.add(this.OldStockInvForecast_Macau);
        nplForecasts.add(this.OldStockInvForecast_Mongolia);
        
        nplForecasts.add(this.OldStockDepletForecast_South);
        nplForecasts.add(this.OldStockDepletForecast_East);
        nplForecasts.add(this.OldStockDepletForecast_Central);
        nplForecasts.add(this.OldStockDepletForecast_North);
        nplForecasts.add(this.OldStockDepletForecast_NorthWest);
        nplForecasts.add(this.OldStockDepletForecast_SouthWest);
        nplForecasts.add(this.OldStockDepletForecast_Macau);
        nplForecasts.add(this.OldStockDepletForecast_Mongolia);  
        
        update nplForecasts;
        update nplHeader;

        //update newProductLaunchForecasts; //20190111 Alan Lau
        
        List<ASI_CN_NPL_NPL_Forecast__c> nplForecasts_dynamicChannel = new List<ASI_CN_NPL_NPL_Forecast__c>(); 
        for(map<string, ASI_CN_NPL_NPL_Forecast__c> map_f : map_channel_region_forecast.values()){
            nplForecasts_dynamicChannel.addall(map_f.values());
        }
        if(nplForecasts_dynamicChannel.size()>0) upsert nplForecasts_dynamicChannel;
        
        return new PageReference('/' + this.nplId);
    }
    
    public PageReference saveLogInformation(){
        List<ASI_CN_NPL_NPL_Forecast__c> nplForecasts = new List<ASI_CN_NPL_NPL_Forecast__c>(); 
        
        //Add Forecast object into list for mass update        
        nplForecasts.add(this.MonitoringForecast_South);
        nplForecasts.add(this.MonitoringForecast_East);
        nplForecasts.add(this.MonitoringForecast_Central);
        nplForecasts.add(this.MonitoringForecast_North);
        nplForecasts.add(this.MonitoringForecast_NorthWest);
        nplForecasts.add(this.MonitoringForecast_SouthWest);
        nplForecasts.add(this.MonitoringForecast_Macau);
        nplForecasts.add(this.MonitoringForecast_Mongolia);
        //20151222 Ben @ Elufa System
        nplForecasts.add(this.MonitoringForecast_HQ);
        
        update nplForecasts;
        update nplHeader;
        
        return new PageReference('/' + this.nplId);
    }
    
    //20170831 Introv
    public PageReference saveAndSubmitForTPApproval(){
        
        if((nplHeader.ASI_NPL_TP_Per_Case_Domestic__c != Null && nplHeader.ASI_NPL_ETA_Domestic__c != Null) || (nplHeader.ASI_NPL_TP_Per_Case__c != Null && nplHeader.ASI_NPL_ETA__c != Null)){
            
            List<ASI_CN_NPL_NPL_Forecast__c> nplForecasts = new List<ASI_CN_NPL_NPL_Forecast__c>(); 
            
            //Add Forecast object into list for mass update        
            nplForecasts.add(this.MonitoringForecast_South);
            nplForecasts.add(this.MonitoringForecast_East);
            nplForecasts.add(this.MonitoringForecast_Central);
            nplForecasts.add(this.MonitoringForecast_North);
            nplForecasts.add(this.MonitoringForecast_NorthWest);
            nplForecasts.add(this.MonitoringForecast_SouthWest);
            nplForecasts.add(this.MonitoringForecast_Macau);
            nplForecasts.add(this.MonitoringForecast_Mongolia);
            //20151222 Ben @ Elufa System
            nplForecasts.add(this.MonitoringForecast_HQ);
            
            try{
                
                update nplForecasts;
                update nplHeader;
                
            }catch(dmlException dmle){
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, dmle.getMessage()));
                return null;
            }
            
            return new PageReference('/Apex/ASI_CN_SubmitApprovalPage?id=' + this.nplId);
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please input TP Per Case and ETA for Domestic/Macau and Mongolia before submitting for approval'));
            return null;
        }
    }
    //20170831 End
    
    private string getMonthName(Date inputDate){
        Integer month = inputDate.month();
        
        if (month ==1)
            return 'Jan';
        else if (month == 2)
            return 'Feb';
        else if (month == 3)
            return 'Mar';
        else if (month == 4)
            return 'Apr';
        else if (month == 5)
            return 'May';
        else if (month == 6)
            return 'Jun';
        else if (month == 7)
            return 'Jul';
        else if (month == 8)
            return 'Aug';
        else if (month == 9)
            return 'Sep';
        else if (month == 10)
            return 'Oct';
        else if (month == 11)
            return 'Nov';
        else if (month == 12)
            return 'Dec';
        else 
            return '';
    }
    
    public void initPage() {        
        List<ASI_CN_NPL_NPL_Forecast__c> nplForecasts = new List<ASI_CN_NPL_NPL_Forecast__c>();
        
        nplForecasts = [SELECT Id, ASI_CN_NPL_Type__c, ASI_CN_NPL_Region__c, ASI_CN_NPL_M6__c, ASI_CN_NPL_M5__c, ASI_CN_NPL_M4__c, ASI_CN_NPL_M3__c, 
            ASI_CN_NPL_M2__c, ASI_CN_NPL_M1__c FROM ASI_CN_NPL_NPL_Forecast__c WHERE New_Product_Launch_Request__c = :nplId
            /* Laputa IM004619 BEGIN: for old Sales Forecast section, only retrieve old records */
            and ASI_NPL_Channel__c = null
            /* Laputa IM004619 END */
            ];
        
        System.debug('List size: ' + nplForecasts.size());
        
        Map<String,ASI_CN_NPL_NPL_Forecast__c> nplForecastsMap = new Map<String,ASI_CN_NPL_NPL_Forecast__c>();
        
        for(ASI_CN_NPL_NPL_Forecast__c nplForecast : nplForecasts){
            nplForecastsMap.put(nplForecast.ASI_CN_NPL_Type__c + ' ' + nplForecast.ASI_CN_NPL_Region__c, nplForecast);
            System.debug('Add object to map: ' + nplForecastsMap);
        }
        
        System.debug('Domestic Sales Vol Start Date: ' + nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c);
        if (nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c != null){
        
            SalesVolDomM1 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.year());
            SalesVolDomM2 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(1).year());
            SalesVolDomM3 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(2).year());
            SalesVolDomM4 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(3).year());
            SalesVolDomM5 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(4).year());
            SalesVolDomM6 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_Launch_Date__c.addMonths(5).year());
        }
        else {
            SalesVolDomM1 = 'M1';
            SalesVolDomM2 = 'M2';
            SalesVolDomM3 = 'M3';
            SalesVolDomM4 = 'M4';
            SalesVolDomM5 = 'M5';
            SalesVolDomM6 = 'M6';
        }
        
        //20151222 Ben @ Elufa System
        if (nplHeader.ASI_CN_NPL_HQ_Launch_Date__c != null){
        
            HQSalesVolM1 = getMonthName(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.year());
            HQSalesVolM2 = getMonthName(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(1).year());
            HQSalesVolM3 = getMonthName(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(2).year());
            HQSalesVolM4 = getMonthName(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(3).year());
            HQSalesVolM5 = getMonthName(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(4).year());
            HQSalesVolM6 = getMonthName(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQ_Launch_Date__c.addMonths(5).year());
        }
        else {
            HQSalesVolM1 = 'M1';
            HQSalesVolM2 = 'M2';
            HQSalesVolM3 = 'M3';
            HQSalesVolM4 = 'M4';
            HQSalesVolM5 = 'M5';
            HQSalesVolM6 = 'M6';
        }
        //20151222 End
            
        System.debug('Macau & Mongolia Sales Vol Start Date: ' + nplHeader.ASI_CN_NPL_MM_Launch_Date__c);
        if (nplHeader.ASI_CN_NPL_MM_Launch_Date__c != null){
            SalesVolMMM1 = getMonthName(nplHeader.ASI_CN_NPL_MM_Launch_Date__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.year());
            SalesVolMMM2 = getMonthName(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(1).year());
            SalesVolMMM3 = getMonthName(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(2).year());
            SalesVolMMM4 = getMonthName(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(3).year());
            SalesVolMMM5 = getMonthName(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(4).year());
            SalesVolMMM6 = getMonthName(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MM_Launch_Date__c.addMonths(5).year());
        }
        else {
            SalesVolMMM1 = 'M1';
            SalesVolMMM2 = 'M2';
            SalesVolMMM3 = 'M3';
            SalesVolMMM4 = 'M4';
            SalesVolMMM5 = 'M5';
            SalesVolMMM6 = 'M6';
        }       
        
        if (nplHeader.ASI_CN_NPL_When_to_Launch__c != null){
            SalesVolMongo1 = getMonthName(nplHeader.ASI_CN_NPL_When_to_Launch__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_When_to_Launch__c.year());
            SalesVolMongo2 = getMonthName(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(1).year());
            SalesVolMongo3 = getMonthName(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(2).year());
            SalesVolMongo4 = getMonthName(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(3).year());
            SalesVolMongo5 = getMonthName(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(4).year());
            SalesVolMongo6 = getMonthName(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_When_to_Launch__c.addMonths(5).year());
        }
        else {
            SalesVolMongo1 = 'M1';
            SalesVolMongo2 = 'M2';
            SalesVolMongo3 = 'M3';
            SalesVolMongo4 = 'M4';
            SalesVolMongo5 = 'M5';
            SalesVolMongo6 = 'M6';
        }   
        
        
        System.debug('NPL Old Stock Start Date: ' + nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c);
        if (nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c != null){
            CreateDateM1 = getMonthName(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.year());
            CreateDateM2 = getMonthName(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(1).year());
            CreateDateM3 = getMonthName(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(2).year());
            CreateDateM4 = getMonthName(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(3).year());
            CreateDateM5 = getMonthName(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(4).year());
            CreateDateM6 = getMonthName(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Old_Stock_Start_Date__c.addMonths(5).year());
        }
        else {
            CreateDateM1 = 'M1';
            CreateDateM2 = 'M2';
            CreateDateM3 = 'M3';
            CreateDateM4 = 'M4';
            CreateDateM5 = 'M5';
            CreateDateM6 = 'M6';
        }     
        
        //20151221 Ben @ Elufa System
        /*if (nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c != null){
        
            southActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.year());
            southActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(1).year());
            southActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(2).year());
            southActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(3).year());
            southActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(4).year());
            southActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthActualDepletionMonth__c.addMonths(5).year());
        }
        else {
            southActualDepletionMonth1 = 'M1';
            southActualDepletionMonth2 = 'M2';
            southActualDepletionMonth3 = 'M3';
            southActualDepletionMonth4 = 'M4';
            southActualDepletionMonth5 = 'M5';
            southActualDepletionMonth6 = 'M6';
        }
        
        if (nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c != null){
        
            eastActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.year());
            eastActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(1).year());
            eastActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(2).year());
            eastActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(3).year());
            eastActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(4).year());
            eastActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_EastActualDepletionMonth__c.addMonths(5).year());
        }
        else {
            eastActualDepletionMonth1 = 'M1';
            eastActualDepletionMonth2 = 'M2';
            eastActualDepletionMonth3 = 'M3';
            eastActualDepletionMonth4 = 'M4';
            eastActualDepletionMonth5 = 'M5';
            eastActualDepletionMonth6 = 'M6';
        }
        
        if (nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c != null){
        
            centralActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.year());
            centralActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(1).year());
            centralActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(2).year());
            centralActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(3).year());
            centralActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(4).year());
            centralActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_CentralActualDepletionMonth__c.addMonths(5).year());
        }
        else {
            centralActualDepletionMonth1 = 'M1';
            centralActualDepletionMonth2 = 'M2';
            centralActualDepletionMonth3 = 'M3';
            centralActualDepletionMonth4 = 'M4';
            centralActualDepletionMonth5 = 'M5';
            centralActualDepletionMonth6 = 'M6';
        }
        
        if (nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c != null){
        
            northActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.year());
            northActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(1).year());
            northActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(2).year());
            northActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(3).year());
            northActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(4).year());
            northActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthActualDepletionMonth__c.addMonths(5).year());
        }
        else {
            northActualDepletionMonth1 = 'M1';
            northActualDepletionMonth2 = 'M2';
            northActualDepletionMonth3 = 'M3';
            northActualDepletionMonth4 = 'M4';
            northActualDepletionMonth5 = 'M5';
            northActualDepletionMonth6 = 'M6';
        }
        
        if (nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c != null){
        
            northWestActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.year());
            northWestActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(1).year());
            northWestActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(2).year());
            northWestActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(3).year());
            northWestActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(4).year());
            northWestActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_NorthWestActualDepletionMonth__c.addMonths(5).year());
        }
        else {
            northWestActualDepletionMonth1 = 'M1';
            northWestActualDepletionMonth2 = 'M2';
            northWestActualDepletionMonth3 = 'M3';
            northWestActualDepletionMonth4 = 'M4';
            northWestActualDepletionMonth5 = 'M5';
            northWestActualDepletionMonth6 = 'M6';
        }
        
        if (nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c != null){
        
            southWestActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.year());
            southWestActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(1).year());
            southWestActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(2).year());
            southWestActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(3).year());
            southWestActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(4).year());
            southWestActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_SouthWestActualDepletionMonth__c.addMonths(5).year());
        }
        else {
            southWestActualDepletionMonth1 = 'M1';
            southWestActualDepletionMonth2 = 'M2';
            southWestActualDepletionMonth3 = 'M3';
            southWestActualDepletionMonth4 = 'M4';
            southWestActualDepletionMonth5 = 'M5';
            southWestActualDepletionMonth6 = 'M6';
        }*/
        
        if (nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c != null){
        
            HQActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.year());
            HQActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(1).year());
            HQActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(2).year());
            HQActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(3).year());
            HQActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(4).year());
            HQActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_HQActualDelpetionMonth__c.addMonths(5).year());
        }
        else {
            HQActualDepletionMonth1 = 'M1';
            HQActualDepletionMonth2 = 'M2';
            HQActualDepletionMonth3 = 'M3';
            HQActualDepletionMonth4 = 'M4';
            HQActualDepletionMonth5 = 'M5';
            HQActualDepletionMonth6 = 'M6';
        }
        
        if (nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c != null){
        
            domestucActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.year());
            domestucActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(1).year());
            domestucActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(2).year());
            domestucActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(3).year());
            domestucActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(4).year());
            domestucActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_Domestic_ActualDepletionMonth__c.addMonths(5).year());
        }
        else {
            domestucActualDepletionMonth1 = 'M1';
            domestucActualDepletionMonth2 = 'M2';
            domestucActualDepletionMonth3 = 'M3';
            domestucActualDepletionMonth4 = 'M4';
            domestucActualDepletionMonth5 = 'M5';
            domestucActualDepletionMonth6 = 'M6';
        }
        
        if (nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c != null){
        
            macauMongoliaActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.year());
            macauMongoliaActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(1).year());
            macauMongoliaActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(2).year());
            macauMongoliaActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(3).year());
            macauMongoliaActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(4).year());
            macauMongoliaActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacMongo_ActualDepletionMonth__c.addMonths(5).year());
        }
        else {
            macauMongoliaActualDepletionMonth1 = 'M1';
            macauMongoliaActualDepletionMonth2 = 'M2';
            macauMongoliaActualDepletionMonth3 = 'M3';
            macauMongoliaActualDepletionMonth4 = 'M4';
            macauMongoliaActualDepletionMonth5 = 'M5';
            macauMongoliaActualDepletionMonth6 = 'M6';
        }
        
        /*if (nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c != null){
        
            MacauActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.year());
            MacauActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(1).year());
            MacauActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(2).year());
            MacauActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(3).year());
            MacauActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(4).year());
            MacauActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MacauActualDelpetionMonth__c.addMonths(5).year());
        }
        else {
            MacauActualDepletionMonth1 = 'M1';
            MacauActualDepletionMonth2 = 'M2';
            MacauActualDepletionMonth3 = 'M3';
            MacauActualDepletionMonth4 = 'M4';
            MacauActualDepletionMonth5 = 'M5';
            MacauActualDepletionMonth6 = 'M6';
        }
        
        if (nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c != null){
        
            mongoliaActualDepletionMonth1 = getMonthName(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.year());
            mongoliaActualDepletionMonth2 = getMonthName(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(1)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(1).year());
            mongoliaActualDepletionMonth3 = getMonthName(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(2)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(2).year());
            mongoliaActualDepletionMonth4 = getMonthName(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(3)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(3).year());
            mongoliaActualDepletionMonth5 = getMonthName(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(4)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(4).year());
            mongoliaActualDepletionMonth6 = getMonthName(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(5)) + '-' + String.valueOf(nplHeader.ASI_CN_NPL_MongoliaActualDelpetionMonth__c.addMonths(5).year());
        }
        else {
            mongoliaActualDepletionMonth1 = 'M1';
            mongoliaActualDepletionMonth2 = 'M2';
            mongoliaActualDepletionMonth3 = 'M3';
            mongoliaActualDepletionMonth4 = 'M4';
            mongoliaActualDepletionMonth5 = 'M5';
            mongoliaActualDepletionMonth6 = 'M6';
        }*/
        
        //20151221 End
        
        //Assign forecast object to each type and region
        this.SalesVolForecast_South = nplForecastsMap.get('Sales Volume South');
        this.SalesVolForecast_East = nplForecastsMap.get('Sales Volume East');
        this.SalesVolForecast_Central = nplForecastsMap.get('Sales Volume Central');
        this.SalesVolForecast_North = nplForecastsMap.get('Sales Volume North');
        this.SalesVolForecast_NorthWest = nplForecastsMap.get('Sales Volume North West');
        this.SalesVolForecast_SouthWest = nplForecastsMap.get('Sales Volume South West');
        this.SalesVolForecast_Macau = nplForecastsMap.get('Sales Volume Macau');
        this.SalesVolForecast_Mongolia = nplForecastsMap.get('Sales Volume Mongolia');
        this.SalesVolForecast_STK3 = nplForecastsMap.get('Sales Volume STK3');
        this.SalesVolForecast_HQ = nplForecastsMap.get('Sales Volume HQ');
        
        this.OldStockInvForecast_South = nplForecastsMap.get('Old Stock Inventory South');
        this.OldStockInvForecast_East = nplForecastsMap.get('Old Stock Inventory East');
        this.OldStockInvForecast_Central = nplForecastsMap.get('Old Stock Inventory Central');
        this.OldStockInvForecast_North = nplForecastsMap.get('Old Stock Inventory North');
        this.OldStockInvForecast_NorthWest = nplForecastsMap.get('Old Stock Inventory North West');
        this.OldStockInvForecast_SouthWest = nplForecastsMap.get('Old Stock Inventory South West');
        this.OldStockInvForecast_Macau = nplForecastsMap.get('Old Stock Inventory Macau');
        this.OldStockInvForecast_Mongolia = nplForecastsMap.get('Old Stock Inventory Mongolia');
        
        this.OldStockDepletForecast_South = nplForecastsMap.get('Old Stock Depletion South');
        this.OldStockDepletForecast_East = nplForecastsMap.get('Old Stock Depletion East');
        this.OldStockDepletForecast_Central = nplForecastsMap.get('Old Stock Depletion Central');
        this.OldStockDepletForecast_North = nplForecastsMap.get('Old Stock Depletion North');
        this.OldStockDepletForecast_NorthWest = nplForecastsMap.get('Old Stock Depletion North West');
        this.OldStockDepletForecast_SouthWest = nplForecastsMap.get('Old Stock Depletion South West');
        this.OldStockDepletForecast_Macau = nplForecastsMap.get('Old Stock Depletion Macau');
        this.OldStockDepletForecast_Mongolia = nplForecastsMap.get('Old Stock Depletion Mongolia');       

        this.MonitoringForecast_South = nplForecastsMap.get('Monitoring South');
        this.MonitoringForecast_East = nplForecastsMap.get('Monitoring East');
        this.MonitoringForecast_Central = nplForecastsMap.get('Monitoring Central');
        this.MonitoringForecast_North = nplForecastsMap.get('Monitoring North');
        this.MonitoringForecast_NorthWest = nplForecastsMap.get('Monitoring North West');
        this.MonitoringForecast_SouthWest = nplForecastsMap.get('Monitoring South West');
        this.MonitoringForecast_Macau = nplForecastsMap.get('Monitoring Macau');
        this.MonitoringForecast_Mongolia = nplForecastsMap.get('Monitoring Mongolia');  
        //20151222 Ben @ Elufa System
        this.MonitoringForecast_HQ = nplForecastsMap.get('Monitoring HQ');
            
        MonitorVarSouth = new Map<String, Decimal>();        
        MonitorVarEast = new Map<String, Decimal>();        
        MonitorVarCentral = new Map<String, Decimal>();        
        MonitorVarNorth = new Map<String, Decimal>();        
        MonitorVarNorthWest = new Map<String, Decimal>();        
        MonitorVarSouthWest = new Map<String, Decimal>();        
        MonitorVarMacau = new Map<String, Decimal>();        
        MonitorVarMongolia = new Map<String, Decimal>();
        //20151222 Ben @ Elufa System
        MonitorVarHQ = new Map<String, Decimal>();

        //Variance for South
        if (SalesVolForecast_South.ASI_CN_NPL_M1__c != null && MonitoringForecast_South.ASI_CN_NPL_M1__c != null ){
           MonitorVarSouth.put('M1', MonitoringForecast_South.ASI_CN_NPL_M1__c - SalesVolForecast_South.ASI_CN_NPL_M1__c);
        } else {
           MonitorVarSouth.put('M1',0);
        }       
        
        if (SalesVolForecast_South.ASI_CN_NPL_M2__c != null && MonitoringForecast_South.ASI_CN_NPL_M2__c != null ){
           MonitorVarSouth.put('M2', MonitoringForecast_South.ASI_CN_NPL_M2__c - SalesVolForecast_South.ASI_CN_NPL_M2__c);
        } else {
           MonitorVarSouth.put('M2',0);
        }
        
        if (SalesVolForecast_South.ASI_CN_NPL_M3__c != null && MonitoringForecast_South.ASI_CN_NPL_M3__c != null ){
           MonitorVarSouth.put('M3', MonitoringForecast_South.ASI_CN_NPL_M3__c - SalesVolForecast_South.ASI_CN_NPL_M3__c);
        } else {
           MonitorVarSouth.put('M3',0);
        }

        if (SalesVolForecast_South.ASI_CN_NPL_M4__c != null && MonitoringForecast_South.ASI_CN_NPL_M4__c != null ){
           MonitorVarSouth.put('M4', MonitoringForecast_South.ASI_CN_NPL_M4__c - SalesVolForecast_South.ASI_CN_NPL_M4__c);
        } else {
           MonitorVarSouth.put('M4',0);
        }
        
        if (SalesVolForecast_South.ASI_CN_NPL_M5__c != null && MonitoringForecast_South.ASI_CN_NPL_M5__c != null ){
           MonitorVarSouth.put('M5', MonitoringForecast_South.ASI_CN_NPL_M5__c - SalesVolForecast_South.ASI_CN_NPL_M5__c);
        } else {
           MonitorVarSouth.put('M5',0);
        }

        if (SalesVolForecast_South.ASI_CN_NPL_M6__c != null && MonitoringForecast_South.ASI_CN_NPL_M6__c != null ){
           MonitorVarSouth.put('M6', MonitoringForecast_South.ASI_CN_NPL_M6__c - SalesVolForecast_South.ASI_CN_NPL_M6__c);
        } else {
           MonitorVarSouth.put('M6',0);
        }
        
        //Variance for East
        if (SalesVolForecast_East.ASI_CN_NPL_M1__c != null && MonitoringForecast_East.ASI_CN_NPL_M1__c != null ){
           MonitorVarEast.put('M1', MonitoringForecast_East.ASI_CN_NPL_M1__c - SalesVolForecast_East.ASI_CN_NPL_M1__c);
        } else {
           MonitorVarEast.put('M1',0);
        }       
        
        if (SalesVolForecast_East.ASI_CN_NPL_M2__c != null && MonitoringForecast_East.ASI_CN_NPL_M2__c != null ){
           MonitorVarEast.put('M2', MonitoringForecast_East.ASI_CN_NPL_M2__c - SalesVolForecast_East.ASI_CN_NPL_M2__c);
        } else {
           MonitorVarEast.put('M2',0);
        }
        
        if (SalesVolForecast_East.ASI_CN_NPL_M3__c != null && MonitoringForecast_East.ASI_CN_NPL_M3__c != null ){
           MonitorVarEast.put('M3', MonitoringForecast_East.ASI_CN_NPL_M3__c - SalesVolForecast_East.ASI_CN_NPL_M3__c);
        } else {
           MonitorVarEast.put('M3',0);
        }

        if (SalesVolForecast_East.ASI_CN_NPL_M4__c != null && MonitoringForecast_East.ASI_CN_NPL_M4__c != null ){
           MonitorVarEast.put('M4', MonitoringForecast_East.ASI_CN_NPL_M4__c - SalesVolForecast_East.ASI_CN_NPL_M4__c);
        } else {
           MonitorVarEast.put('M4',0);
        }
        
        if (SalesVolForecast_East.ASI_CN_NPL_M5__c != null && MonitoringForecast_East.ASI_CN_NPL_M5__c != null ){
           MonitorVarEast.put('M5', MonitoringForecast_East.ASI_CN_NPL_M5__c - SalesVolForecast_East.ASI_CN_NPL_M5__c);
        } else {
           MonitorVarEast.put('M5',0);
        }

        if (SalesVolForecast_East.ASI_CN_NPL_M6__c != null && MonitoringForecast_East.ASI_CN_NPL_M6__c != null ){
           MonitorVarEast.put('M6', MonitoringForecast_East.ASI_CN_NPL_M6__c - SalesVolForecast_East.ASI_CN_NPL_M6__c);
        } else {
           MonitorVarEast.put('M6',0);
        }
        
        //Variance for Central
        if (SalesVolForecast_Central.ASI_CN_NPL_M1__c != null && MonitoringForecast_Central.ASI_CN_NPL_M1__c != null ){
           MonitorVarCentral.put('M1', MonitoringForecast_Central.ASI_CN_NPL_M1__c - SalesVolForecast_Central.ASI_CN_NPL_M1__c);
        } else {
           MonitorVarCentral.put('M1',0);
        }       
        
        if (SalesVolForecast_Central.ASI_CN_NPL_M2__c != null && MonitoringForecast_Central.ASI_CN_NPL_M2__c != null ){
           MonitorVarCentral.put('M2', MonitoringForecast_Central.ASI_CN_NPL_M2__c - SalesVolForecast_Central.ASI_CN_NPL_M2__c);
        } else {
           MonitorVarCentral.put('M2',0);
        }
        
        if (SalesVolForecast_Central.ASI_CN_NPL_M3__c != null && MonitoringForecast_Central.ASI_CN_NPL_M3__c != null ){
           MonitorVarCentral.put('M3', MonitoringForecast_Central.ASI_CN_NPL_M3__c - SalesVolForecast_Central.ASI_CN_NPL_M3__c);
        } else {
           MonitorVarCentral.put('M3',0);
        }

        if (SalesVolForecast_Central.ASI_CN_NPL_M4__c != null && MonitoringForecast_Central.ASI_CN_NPL_M4__c != null ){
           MonitorVarCentral.put('M4', MonitoringForecast_Central.ASI_CN_NPL_M4__c - SalesVolForecast_Central.ASI_CN_NPL_M4__c);
        } else {
           MonitorVarCentral.put('M4',0);
        }
        
        if (SalesVolForecast_Central.ASI_CN_NPL_M5__c != null && MonitoringForecast_Central.ASI_CN_NPL_M5__c != null ){
           MonitorVarCentral.put('M5', MonitoringForecast_Central.ASI_CN_NPL_M5__c - SalesVolForecast_Central.ASI_CN_NPL_M5__c);
        } else {
           MonitorVarCentral.put('M5',0);
        }

        if (SalesVolForecast_Central.ASI_CN_NPL_M6__c != null && MonitoringForecast_Central.ASI_CN_NPL_M6__c != null ){
           MonitorVarCentral.put('M6', MonitoringForecast_Central.ASI_CN_NPL_M6__c - SalesVolForecast_Central.ASI_CN_NPL_M6__c);
        } else {
           MonitorVarCentral.put('M6',0);
        }
        
        //Variance for North
        if (SalesVolForecast_North.ASI_CN_NPL_M1__c != null && MonitoringForecast_North.ASI_CN_NPL_M1__c != null ){
           MonitorVarNorth.put('M1', MonitoringForecast_North.ASI_CN_NPL_M1__c - SalesVolForecast_North.ASI_CN_NPL_M1__c);
        } else {
           MonitorVarNorth.put('M1',0);
        }       
        
        if (SalesVolForecast_North.ASI_CN_NPL_M2__c != null && MonitoringForecast_North.ASI_CN_NPL_M2__c != null ){
           MonitorVarNorth.put('M2', MonitoringForecast_North.ASI_CN_NPL_M2__c - SalesVolForecast_North.ASI_CN_NPL_M2__c);
        } else {
           MonitorVarNorth.put('M2',0);
        }
        
        if (SalesVolForecast_North.ASI_CN_NPL_M3__c != null && MonitoringForecast_North.ASI_CN_NPL_M3__c != null ){
           MonitorVarNorth.put('M3', MonitoringForecast_North.ASI_CN_NPL_M3__c - SalesVolForecast_North.ASI_CN_NPL_M3__c);
        } else {
           MonitorVarNorth.put('M3',0);
        }

        if (SalesVolForecast_North.ASI_CN_NPL_M4__c != null && MonitoringForecast_North.ASI_CN_NPL_M4__c != null ){
           MonitorVarNorth.put('M4', MonitoringForecast_North.ASI_CN_NPL_M4__c - SalesVolForecast_North.ASI_CN_NPL_M4__c);
        } else {
           MonitorVarNorth.put('M4',0);
        }
        
        if (SalesVolForecast_North.ASI_CN_NPL_M5__c != null && MonitoringForecast_North.ASI_CN_NPL_M5__c != null ){
           MonitorVarNorth.put('M5', MonitoringForecast_North.ASI_CN_NPL_M5__c - SalesVolForecast_North.ASI_CN_NPL_M5__c);
        } else {
           MonitorVarNorth.put('M5',0);
        }

        if (SalesVolForecast_North.ASI_CN_NPL_M6__c != null && MonitoringForecast_North.ASI_CN_NPL_M6__c != null ){
           MonitorVarNorth.put('M6', MonitoringForecast_North.ASI_CN_NPL_M6__c - SalesVolForecast_North.ASI_CN_NPL_M6__c);
        } else {
           MonitorVarNorth.put('M6',0);
        }
        
        //Variance for NorthWest
        if (SalesVolForecast_NorthWest.ASI_CN_NPL_M1__c != null && MonitoringForecast_NorthWest.ASI_CN_NPL_M1__c != null ){
           MonitorVarNorthWest.put('M1', MonitoringForecast_NorthWest.ASI_CN_NPL_M1__c - SalesVolForecast_NorthWest.ASI_CN_NPL_M1__c);
        } else {
           MonitorVarNorthWest.put('M1',0);
        }       
        
        if (SalesVolForecast_NorthWest.ASI_CN_NPL_M2__c != null && MonitoringForecast_NorthWest.ASI_CN_NPL_M2__c != null ){
           MonitorVarNorthWest.put('M2', MonitoringForecast_NorthWest.ASI_CN_NPL_M2__c - SalesVolForecast_NorthWest.ASI_CN_NPL_M2__c);
        } else {
           MonitorVarNorthWest.put('M2',0);
        }
        
        if (SalesVolForecast_NorthWest.ASI_CN_NPL_M3__c != null && MonitoringForecast_NorthWest.ASI_CN_NPL_M3__c != null ){
           MonitorVarNorthWest.put('M3', MonitoringForecast_NorthWest.ASI_CN_NPL_M3__c - SalesVolForecast_NorthWest.ASI_CN_NPL_M3__c);
        } else {
           MonitorVarNorthWest.put('M3',0);
        }

        if (SalesVolForecast_NorthWest.ASI_CN_NPL_M4__c != null && MonitoringForecast_NorthWest.ASI_CN_NPL_M4__c != null ){
           MonitorVarNorthWest.put('M4', MonitoringForecast_NorthWest.ASI_CN_NPL_M4__c - SalesVolForecast_NorthWest.ASI_CN_NPL_M4__c);
        } else {
           MonitorVarNorthWest.put('M4',0);
        }
        
        if (SalesVolForecast_NorthWest.ASI_CN_NPL_M5__c != null && MonitoringForecast_NorthWest.ASI_CN_NPL_M5__c != null ){
           MonitorVarNorthWest.put('M5', MonitoringForecast_NorthWest.ASI_CN_NPL_M5__c - SalesVolForecast_NorthWest.ASI_CN_NPL_M5__c);
        } else {
           MonitorVarNorthWest.put('M5',0);
        }

        if (SalesVolForecast_NorthWest.ASI_CN_NPL_M6__c != null && MonitoringForecast_NorthWest.ASI_CN_NPL_M6__c != null ){
           MonitorVarNorthWest.put('M6', MonitoringForecast_NorthWest.ASI_CN_NPL_M6__c - SalesVolForecast_NorthWest.ASI_CN_NPL_M6__c);
        } else {
           MonitorVarNorthWest.put('M6',0);
        }
        
        //Variance for SouthWest
        if (SalesVolForecast_SouthWest.ASI_CN_NPL_M1__c != null && MonitoringForecast_SouthWest.ASI_CN_NPL_M1__c != null ){
           MonitorVarSouthWest.put('M1', MonitoringForecast_SouthWest.ASI_CN_NPL_M1__c - SalesVolForecast_SouthWest.ASI_CN_NPL_M1__c);
        } else {
           MonitorVarSouthWest.put('M1',0);
        }       
        
        if (SalesVolForecast_SouthWest.ASI_CN_NPL_M2__c != null && MonitoringForecast_SouthWest.ASI_CN_NPL_M2__c != null ){
           MonitorVarSouthWest.put('M2', MonitoringForecast_SouthWest.ASI_CN_NPL_M2__c - SalesVolForecast_SouthWest.ASI_CN_NPL_M2__c);
        } else {
           MonitorVarSouthWest.put('M2',0);
        }
        
        if (SalesVolForecast_SouthWest.ASI_CN_NPL_M3__c != null && MonitoringForecast_SouthWest.ASI_CN_NPL_M3__c != null ){
           MonitorVarSouthWest.put('M3', MonitoringForecast_SouthWest.ASI_CN_NPL_M3__c - SalesVolForecast_SouthWest.ASI_CN_NPL_M3__c);
        } else {
           MonitorVarSouthWest.put('M3',0);
        }

        if (SalesVolForecast_SouthWest.ASI_CN_NPL_M4__c != null && MonitoringForecast_SouthWest.ASI_CN_NPL_M4__c != null ){
           MonitorVarSouthWest.put('M4', MonitoringForecast_SouthWest.ASI_CN_NPL_M4__c - SalesVolForecast_SouthWest.ASI_CN_NPL_M4__c);
        } else {
           MonitorVarSouthWest.put('M4',0);
        }
        
        if (SalesVolForecast_SouthWest.ASI_CN_NPL_M5__c != null && MonitoringForecast_SouthWest.ASI_CN_NPL_M5__c != null ){
           MonitorVarSouthWest.put('M5', MonitoringForecast_SouthWest.ASI_CN_NPL_M5__c - SalesVolForecast_SouthWest.ASI_CN_NPL_M5__c);
        } else {
           MonitorVarSouthWest.put('M5',0);
        }

        if (SalesVolForecast_SouthWest.ASI_CN_NPL_M6__c != null && MonitoringForecast_SouthWest.ASI_CN_NPL_M6__c != null ){
           MonitorVarSouthWest.put('M6', MonitoringForecast_SouthWest.ASI_CN_NPL_M6__c - SalesVolForecast_SouthWest.ASI_CN_NPL_M6__c);
        } else {
           MonitorVarSouthWest.put('M6',0);
        }
        
        //Variance for Macau
        if (SalesVolForecast_Macau.ASI_CN_NPL_M1__c != null && MonitoringForecast_Macau.ASI_CN_NPL_M1__c != null ){
           MonitorVarMacau.put('M1', MonitoringForecast_Macau.ASI_CN_NPL_M1__c - SalesVolForecast_Macau.ASI_CN_NPL_M1__c);
        } else {
           MonitorVarMacau.put('M1',0);
        }       
        
        if (SalesVolForecast_Macau.ASI_CN_NPL_M2__c != null && MonitoringForecast_Macau.ASI_CN_NPL_M2__c != null ){
           MonitorVarMacau.put('M2', MonitoringForecast_Macau.ASI_CN_NPL_M2__c - SalesVolForecast_Macau.ASI_CN_NPL_M2__c);
        } else {
           MonitorVarMacau.put('M2',0);
        }
        
        if (SalesVolForecast_Macau.ASI_CN_NPL_M3__c != null && MonitoringForecast_Macau.ASI_CN_NPL_M3__c != null ){
           MonitorVarMacau.put('M3', MonitoringForecast_Macau.ASI_CN_NPL_M3__c - SalesVolForecast_Macau.ASI_CN_NPL_M3__c);
        } else {
           MonitorVarMacau.put('M3',0);
        }

        if (SalesVolForecast_Macau.ASI_CN_NPL_M4__c != null && MonitoringForecast_Macau.ASI_CN_NPL_M4__c != null ){
           MonitorVarMacau.put('M4', MonitoringForecast_Macau.ASI_CN_NPL_M4__c - SalesVolForecast_Macau.ASI_CN_NPL_M4__c);
        } else {
           MonitorVarMacau.put('M4',0);
        }
        
        if (SalesVolForecast_Macau.ASI_CN_NPL_M5__c != null && MonitoringForecast_Macau.ASI_CN_NPL_M5__c != null ){
           MonitorVarMacau.put('M5', MonitoringForecast_Macau.ASI_CN_NPL_M5__c - SalesVolForecast_Macau.ASI_CN_NPL_M5__c);
        } else {
           MonitorVarMacau.put('M5',0);
        }

        if (SalesVolForecast_Macau.ASI_CN_NPL_M6__c != null && MonitoringForecast_Macau.ASI_CN_NPL_M6__c != null ){
           MonitorVarMacau.put('M6', MonitoringForecast_Macau.ASI_CN_NPL_M6__c - SalesVolForecast_Macau.ASI_CN_NPL_M6__c);
        } else {
           MonitorVarMacau.put('M6',0);
        }
        
        //Variance for Mongolia
        if (SalesVolForecast_Mongolia.ASI_CN_NPL_M1__c != null && MonitoringForecast_Mongolia.ASI_CN_NPL_M1__c != null ){
           MonitorVarMongolia.put('M1', MonitoringForecast_Mongolia.ASI_CN_NPL_M1__c - SalesVolForecast_Mongolia.ASI_CN_NPL_M1__c);
        } else {
           MonitorVarMongolia.put('M1',0);
        }       
        
        if (SalesVolForecast_Mongolia.ASI_CN_NPL_M2__c != null && MonitoringForecast_Mongolia.ASI_CN_NPL_M2__c != null ){
           MonitorVarMongolia.put('M2', MonitoringForecast_Mongolia.ASI_CN_NPL_M2__c - SalesVolForecast_Mongolia.ASI_CN_NPL_M2__c);
        } else {
           MonitorVarMongolia.put('M2',0);
        }
        
        if (SalesVolForecast_Mongolia.ASI_CN_NPL_M3__c != null && MonitoringForecast_Mongolia.ASI_CN_NPL_M3__c != null ){
           MonitorVarMongolia.put('M3', MonitoringForecast_Mongolia.ASI_CN_NPL_M3__c - SalesVolForecast_Mongolia.ASI_CN_NPL_M3__c);
        } else {
           MonitorVarMongolia.put('M3',0);
        }

        if (SalesVolForecast_Mongolia.ASI_CN_NPL_M4__c != null && MonitoringForecast_Mongolia.ASI_CN_NPL_M4__c != null ){
           MonitorVarMongolia.put('M4', MonitoringForecast_Mongolia.ASI_CN_NPL_M4__c - SalesVolForecast_Mongolia.ASI_CN_NPL_M4__c);
        } else {
           MonitorVarMongolia.put('M4',0);
        }
        
        if (SalesVolForecast_Mongolia.ASI_CN_NPL_M5__c != null && MonitoringForecast_Mongolia.ASI_CN_NPL_M5__c != null ){
           MonitorVarMongolia.put('M5', MonitoringForecast_Mongolia.ASI_CN_NPL_M5__c - SalesVolForecast_Mongolia.ASI_CN_NPL_M5__c);
        } else {
           MonitorVarMongolia.put('M5',0);
        }

        if (SalesVolForecast_Mongolia.ASI_CN_NPL_M6__c != null && MonitoringForecast_Mongolia.ASI_CN_NPL_M6__c != null ){
           MonitorVarMongolia.put('M6', MonitoringForecast_Mongolia.ASI_CN_NPL_M6__c - SalesVolForecast_Mongolia.ASI_CN_NPL_M6__c);
        } else {
           MonitorVarMongolia.put('M6',0);
        }
        
        //20151222 Ben @ Elufa System
        //Variance for HQ
        if (SalesVolForecast_HQ.ASI_CN_NPL_M1__c != null && MonitoringForecast_HQ.ASI_CN_NPL_M1__c != null ){
           MonitorVarHQ.put('M1', MonitoringForecast_HQ.ASI_CN_NPL_M1__c - SalesVolForecast_HQ.ASI_CN_NPL_M1__c);
        } else {
           MonitorVarHQ.put('M1',0);
        }       
        
        if (SalesVolForecast_HQ.ASI_CN_NPL_M2__c != null && MonitoringForecast_HQ.ASI_CN_NPL_M2__c != null ){
           MonitorVarHQ.put('M2', MonitoringForecast_HQ.ASI_CN_NPL_M2__c - SalesVolForecast_HQ.ASI_CN_NPL_M2__c);
        } else {
           MonitorVarHQ.put('M2',0);
        }
        
        if (SalesVolForecast_HQ.ASI_CN_NPL_M3__c != null && MonitoringForecast_HQ.ASI_CN_NPL_M3__c != null ){
           MonitorVarHQ.put('M3', MonitoringForecast_HQ.ASI_CN_NPL_M3__c - SalesVolForecast_HQ.ASI_CN_NPL_M3__c);
        } else {
           MonitorVarHQ.put('M3',0);
        }

        if (SalesVolForecast_HQ.ASI_CN_NPL_M4__c != null && MonitoringForecast_HQ.ASI_CN_NPL_M4__c != null ){
           MonitorVarHQ.put('M4', MonitoringForecast_HQ.ASI_CN_NPL_M4__c - SalesVolForecast_HQ.ASI_CN_NPL_M4__c);
        } else {
           MonitorVarHQ.put('M4',0);
        }
        
        if (SalesVolForecast_HQ.ASI_CN_NPL_M5__c != null && MonitoringForecast_HQ.ASI_CN_NPL_M5__c != null ){
           MonitorVarHQ.put('M5', MonitoringForecast_HQ.ASI_CN_NPL_M5__c - SalesVolForecast_HQ.ASI_CN_NPL_M5__c);
        } else {
           MonitorVarHQ.put('M5',0);
        }

        if (SalesVolForecast_HQ.ASI_CN_NPL_M6__c != null && MonitoringForecast_HQ.ASI_CN_NPL_M6__c != null ){
           MonitorVarHQ.put('M6', MonitoringForecast_HQ.ASI_CN_NPL_M6__c - SalesVolForecast_HQ.ASI_CN_NPL_M6__c);
        } else {
           MonitorVarHQ.put('M6',0);
        }
        //20151222 End
        
        //Initalize varaible
        SalesVolM1Total = 0;
        SalesVolM2Total = 0;
        SalesVolM3Total = 0;
        SalesVolM4Total = 0;
        SalesVolM5Total = 0;
        SalesVolM6Total = 0;

        OldStockInvM1Total = 0;
        OldStockInvM2Total = 0;
        OldStockInvM3Total = 0;
        OldStockInvM4Total = 0;
        OldStockInvM5Total = 0;
        OldStockInvM6Total = 0;
        
        OldStockDepletM1Total = 0;
        OldStockDepletM2Total = 0;
        OldStockDepletM3Total = 0;
        OldStockDepletM4Total = 0;
        OldStockDepletM5Total = 0;
        OldStockDepletM6Total = 0;

        SalesVolM1DomSubTotal = 0;
        SalesVolM2DomSubTotal = 0;
        SalesVolM3DomSubTotal = 0;
        SalesVolM4DomSubTotal = 0;
        SalesVolM5DomSubTotal = 0;
        SalesVolM6DomSubTotal = 0;
    
        SalesVolM1MMSubTotal = 0;
        SalesVolM2MMSubTotal = 0;
        SalesVolM3MMSubTotal = 0;
        SalesVolM4MMSubTotal = 0;
        SalesVolM5MMSubTotal = 0;
        SalesVolM6MMSubTotal = 0;
    
        SalesVolM1STK3DomSubTotal = 0;
        SalesVolM2STK3DomSubTotal = 0;
        SalesVolM3STK3DomSubTotal = 0;
        SalesVolM4STK3DomSubTotal = 0;
        SalesVolM5STK3DomSubTotal = 0;
        SalesVolM6STK3DomSubTotal = 0;
        
        MonitorM1DomSubTotal = 0;
        MonitorM2DomSubTotal = 0;
        MonitorM3DomSubTotal = 0;
        MonitorM4DomSubTotal = 0;
        MonitorM5DomSubTotal = 0;
        MonitorM6DomSubTotal = 0;
        
        MonitorM1MMSubTotal = 0;
        MonitorM2MMSubTotal = 0;
        MonitorM3MMSubTotal = 0;
        MonitorM4MMSubTotal = 0;
        MonitorM5MMSubTotal = 0;
        MonitorM6MMSubTotal = 0;
    
        VarM1DomSubTotal = 0;
        VarM2DomSubTotal = 0;
        VarM3DomSubTotal = 0;
        VarM4DomSubTotal = 0;
        VarM5DomSubTotal = 0;
        VarM6DomSubTotal = 0;
    
        VarM1MMSubTotal = 0;
        VarM2MMSubTotal = 0;
        VarM3MMSubTotal = 0;
        VarM4MMSubTotal = 0;
        VarM5MMSubTotal = 0;
        VarM6MMSubTotal = 0;
        
        VarM1DomSubTotal = MonitorVarSouth.get('M1') + MonitorVarEast.get('M1') + MonitorVarCentral.get('M1') + MonitorVarNorth.get('M1') + MonitorVarNorthWest.get('M1') + MonitorVarSouthWest.get('M1');
        VarM2DomSubTotal = MonitorVarSouth.get('M2') + MonitorVarEast.get('M2') + MonitorVarCentral.get('M2') + MonitorVarNorth.get('M2') + MonitorVarNorthWest.get('M2') + MonitorVarSouthWest.get('M2');
        VarM3DomSubTotal = MonitorVarSouth.get('M3') + MonitorVarEast.get('M3') + MonitorVarCentral.get('M3') + MonitorVarNorth.get('M3') + MonitorVarNorthWest.get('M3') + MonitorVarSouthWest.get('M3');
        VarM4DomSubTotal = MonitorVarSouth.get('M4') + MonitorVarEast.get('M4') + MonitorVarCentral.get('M4') + MonitorVarNorth.get('M4') + MonitorVarNorthWest.get('M4') + MonitorVarSouthWest.get('M4');
        VarM5DomSubTotal = MonitorVarSouth.get('M5') + MonitorVarEast.get('M5') + MonitorVarCentral.get('M5') + MonitorVarNorth.get('M5') + MonitorVarNorthWest.get('M5') + MonitorVarSouthWest.get('M5');
        VarM6DomSubTotal = MonitorVarSouth.get('M6') + MonitorVarEast.get('M6') + MonitorVarCentral.get('M6') + MonitorVarNorth.get('M6') + MonitorVarNorthWest.get('M6') + MonitorVarSouthWest.get('M6');
    
        VarM1MMSubTotal = MonitorVarMacau.get('M1') + MonitorVarMongolia.get('M1');
        VarM2MMSubTotal = MonitorVarMacau.get('M2') + MonitorVarMongolia.get('M2');
        VarM3MMSubTotal = MonitorVarMacau.get('M3') + MonitorVarMongolia.get('M3');
        VarM4MMSubTotal = MonitorVarMacau.get('M4') + MonitorVarMongolia.get('M4');
        VarM5MMSubTotal = MonitorVarMacau.get('M5') + MonitorVarMongolia.get('M5');
        VarM6MMSubTotal = MonitorVarMacau.get('M6') + MonitorVarMongolia.get('M6');     
        
        for (ASI_CN_NPL_NPL_Forecast__c nplForecast : nplForecasts){            
            if (nplForecast.ASI_CN_NPL_Type__c == 'Sales Volume'){
                System.debug('nplForecast.ASI_CN_NPL_Type__c : ' + nplForecast.ASI_CN_NPL_Type__c );
                if (nplForecast.ASI_CN_NPL_M1__c != null){
                    SalesVolM1Total += nplForecast.ASI_CN_NPL_M1__c;
                    
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        SalesVolM1DomSubTotal += nplForecast.ASI_CN_NPL_M1__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        SalesVolM1MMSubTotal += nplForecast.ASI_CN_NPL_M1__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'STK3' || nplForecast.ASI_CN_NPL_Region__c == 'HQ'){
                        SalesVolM1STK3DomSubTotal += nplForecast.ASI_CN_NPL_M1__c;
                    }
                }
                
                if (nplForecast.ASI_CN_NPL_M2__c != null){
                    SalesVolM2Total += nplForecast.ASI_CN_NPL_M2__c;
                    
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        SalesVolM2DomSubTotal += nplForecast.ASI_CN_NPL_M2__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        SalesVolM2MMSubTotal += nplForecast.ASI_CN_NPL_M2__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'STK3' || nplForecast.ASI_CN_NPL_Region__c == 'HQ'){
                        SalesVolM2STK3DomSubTotal += nplForecast.ASI_CN_NPL_M2__c;
                    }
                }
                    
                if (nplForecast.ASI_CN_NPL_M3__c != null){
                    SalesVolM3Total += nplForecast.ASI_CN_NPL_M3__c;
                                        
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        SalesVolM3DomSubTotal += nplForecast.ASI_CN_NPL_M3__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        SalesVolM3MMSubTotal += nplForecast.ASI_CN_NPL_M3__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'STK3' || nplForecast.ASI_CN_NPL_Region__c == 'HQ'){
                        SalesVolM3STK3DomSubTotal += nplForecast.ASI_CN_NPL_M3__c;
                    }
                }
                
                if (nplForecast.ASI_CN_NPL_M4__c != null){
                    SalesVolM4Total += nplForecast.ASI_CN_NPL_M4__c;
                                        
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        SalesVolM4DomSubTotal += nplForecast.ASI_CN_NPL_M4__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        SalesVolM4MMSubTotal += nplForecast.ASI_CN_NPL_M4__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'STK3' || nplForecast.ASI_CN_NPL_Region__c == 'HQ'){
                        SalesVolM4STK3DomSubTotal += nplForecast.ASI_CN_NPL_M4__c;
                    }
                }
                    
                if (nplForecast.ASI_CN_NPL_M5__c != null){
                    SalesVolM5Total += nplForecast.ASI_CN_NPL_M5__c;
                                        
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        SalesVolM5DomSubTotal += nplForecast.ASI_CN_NPL_M5__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        SalesVolM5MMSubTotal += nplForecast.ASI_CN_NPL_M5__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'STK3' || nplForecast.ASI_CN_NPL_Region__c == 'HQ'){
                        SalesVolM5STK3DomSubTotal += nplForecast.ASI_CN_NPL_M5__c;
                    }
                }
                    
                if (nplForecast.ASI_CN_NPL_M6__c != null){
                    SalesVolM6Total += nplForecast.ASI_CN_NPL_M6__c;            
                                        
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        SalesVolM6DomSubTotal += nplForecast.ASI_CN_NPL_M6__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        SalesVolM6MMSubTotal += nplForecast.ASI_CN_NPL_M6__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'STK3' || nplForecast.ASI_CN_NPL_Region__c == 'HQ'){
                        SalesVolM6STK3DomSubTotal += nplForecast.ASI_CN_NPL_M6__c;
                    }
                }
            }
            else if (nplForecast.ASI_CN_NPL_Type__c == 'Old Stock Inventory'){
                System.debug('nplForecast.ASI_CN_NPL_Type__c : ' + nplForecast.ASI_CN_NPL_Type__c );
                if (nplForecast.ASI_CN_NPL_M1__c != null)
                    OldStockInvM1Total += nplForecast.ASI_CN_NPL_M1__c;
                    
                if (nplForecast.ASI_CN_NPL_M2__c != null)
                    OldStockInvM2Total += nplForecast.ASI_CN_NPL_M2__c;
                    
                if (nplForecast.ASI_CN_NPL_M3__c != null)
                    OldStockInvM3Total += nplForecast.ASI_CN_NPL_M3__c;
                    
                if (nplForecast.ASI_CN_NPL_M4__c != null)
                    OldStockInvM4Total += nplForecast.ASI_CN_NPL_M4__c;
                    
                if (nplForecast.ASI_CN_NPL_M5__c != null)
                    OldStockInvM5Total += nplForecast.ASI_CN_NPL_M5__c;
                    
                if (nplForecast.ASI_CN_NPL_M6__c != null)
                    OldStockInvM6Total += nplForecast.ASI_CN_NPL_M6__c;            
            }
            else if (nplForecast.ASI_CN_NPL_Type__c == 'Old Stock Depletion'){
                System.debug('nplForecast.ASI_CN_NPL_Type__c : ' + nplForecast.ASI_CN_NPL_Type__c );
                if (nplForecast.ASI_CN_NPL_M1__c != null)
                    OldStockDepletM1Total += nplForecast.ASI_CN_NPL_M1__c;
                    
                if (nplForecast.ASI_CN_NPL_M2__c != null)
                    OldStockDepletM2Total += nplForecast.ASI_CN_NPL_M2__c;
                    
                if (nplForecast.ASI_CN_NPL_M3__c != null)
                    OldStockDepletM3Total += nplForecast.ASI_CN_NPL_M3__c;
                    
                if (nplForecast.ASI_CN_NPL_M4__c != null)
                    OldStockDepletM4Total += nplForecast.ASI_CN_NPL_M4__c;
                    
                if (nplForecast.ASI_CN_NPL_M5__c != null)
                    OldStockDepletM5Total += nplForecast.ASI_CN_NPL_M5__c;
                    
                if (nplForecast.ASI_CN_NPL_M6__c != null)
                    OldStockDepletM6Total += nplForecast.ASI_CN_NPL_M6__c;            
            }
            else if (nplForecast.ASI_CN_NPL_Type__c == 'Monitoring'){
                if (nplForecast.ASI_CN_NPL_M1__c != null){                  
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        MonitorM1DomSubTotal += nplForecast.ASI_CN_NPL_M1__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        MonitorM1MMSubTotal += nplForecast.ASI_CN_NPL_M1__c;
                    }
                }
                
                if (nplForecast.ASI_CN_NPL_M2__c != null){                  
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        MonitorM2DomSubTotal += nplForecast.ASI_CN_NPL_M2__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        MonitorM2MMSubTotal += nplForecast.ASI_CN_NPL_M2__c;
                    }
                }
                
                if (nplForecast.ASI_CN_NPL_M3__c != null){                  
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        MonitorM3DomSubTotal += nplForecast.ASI_CN_NPL_M3__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        MonitorM3MMSubTotal += nplForecast.ASI_CN_NPL_M3__c;
                    }
                }
                
                if (nplForecast.ASI_CN_NPL_M4__c != null){                  
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        MonitorM4DomSubTotal += nplForecast.ASI_CN_NPL_M4__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        MonitorM4MMSubTotal += nplForecast.ASI_CN_NPL_M4__c;
                    }
                }
                
                if (nplForecast.ASI_CN_NPL_M5__c != null){                  
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        MonitorM5DomSubTotal += nplForecast.ASI_CN_NPL_M5__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        MonitorM5MMSubTotal += nplForecast.ASI_CN_NPL_M5__c;
                    }
                }
                
                if (nplForecast.ASI_CN_NPL_M6__c != null){                  
                    if (nplForecast.ASI_CN_NPL_Region__c == 'Central' || nplForecast.ASI_CN_NPL_Region__c == 'North' || nplForecast.ASI_CN_NPL_Region__c == 'East' || nplForecast.ASI_CN_NPL_Region__c == 'South' ||
                        nplForecast.ASI_CN_NPL_Region__c == 'South West' || nplForecast.ASI_CN_NPL_Region__c == 'North West'){
                        MonitorM6DomSubTotal += nplForecast.ASI_CN_NPL_M6__c;
                    }
                    else if (nplForecast.ASI_CN_NPL_Region__c == 'Macau' || nplForecast.ASI_CN_NPL_Region__c == 'Mongolia'){
                        MonitorM6MMSubTotal += nplForecast.ASI_CN_NPL_M6__c;
                    }
                }
            }
        }
    }

    private List<String> getStrings(List<SObject> sobjs, String fieldName) { //20190112 Alan Lau
        List<String> strings = new List<String>();
        for(SObject sobj : sobjs) {
            String stringFieldValue = (String) sobj.get(fieldName);
            if(String.isNotBlank(stringFieldValue) && !strings.contains(stringFieldValue)) {
                strings.add(stringFieldValue);
            }
        }
        return strings;
    }
}