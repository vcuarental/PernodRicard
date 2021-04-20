/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 03/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_VFC15_CotasReportController {
    
    public LAT_CotaMarket__c filterCota           {get; set;}
    public LAT_DetalheCotaMarket__c dummyLookup   {get; set;}
    public List<DataWrap> consumed                {get; set;}
    public Boolean ExportToExcel                  {get;set;}
    
    public LAT_BR_VFC15_CotasReportController (){
        this.filterCota = new LAT_CotaMarket__c();
        this.dummyLookup = new LAT_DetalheCotaMarket__c();
        this.consumed = new List<DataWrap>();
        this.ExportToExcel = false;

        if (ApexPages.currentPage().getParameters().get('export') != null ) {
            this.ExportToExcel = true;
        }

        String cotaId = ApexPages.currentPage().getParameters().get('id');
        if (cotaId != null) {
            this.dummyLookup.cotaMarket__c = cotaId;
            this.refreshLists();
        }
    }
    
    public void refreshLists() {
        if(!Utils.wasMigrationDone('1')){
            List<LAT_CotaMarket__c> cotaList = [SELECT id, Name, totalCota__c, SKU__r.Name, endDate__c, startDate__c,
                                                        InitDate__c, totalConsumido__c, totalDistribuido__c, 
                                                        (Select id FROM Detalhes_Cota__r) 
                                                    FROM LAT_CotaMarket__c 
                                                    WHERE id =: this.dummyLookup.cotaMarket__c];
            
            consumed.clear();
            if (!cotaList.isEmpty()) {
                filterCota = cotaList.get(0);
                List<String> detalhCotaIds = new List<String>();
                for (LAT_DetalheCotaMarket__c dcm : filterCota.Detalhes_Cota__r){
                    detalhCotaIds.add(dcm.id);
                }
                
                List<OpportunityLineItem> oliList = [SELECT id, OpportunityId, Cota_Consumida__c, Cota_Consumida__r.Name, Cota_Consumida__r.segmento__r.Name, Cota_Consumida__r.sub_canal__c,
                                                             Cota_Consumida__r.regional__r.Name, Cota_Consumida__r.bandeira__r.Name, Cota_Consumida__r.cantidadDisponible__c,
                                                             Cota_Consumida__r.executivo__r.Name, Cota_Consumida__r.cliente__r.Name, Cota_Consumida__r.cliente__c, 
                                                             Cota_Consumida__r.startDate__c, Cota_Consumida__r.endDate__c, Opportunity.Account.Name, Opportunity.AccountId, 
                                                             cantidadCotaConsumida__c, Opportunity.Name, Opportunity.OwnerId, Opportunity.Owner.Name, Cota_Consumida__r.Cota__c,
                                                             Opportunity.CreatedDate, Opportunity.Account.Client_code_AN8__c, Opportunity.NR_order_JDE__c, Opportunity.Type
                                                        FROM OpportunityLineItem 
                                                        WHERE Cota_Consumida__c IN: detalhCotaIds ORDER BY Opportunity.Name];
                for (OpportunityLineItem oli: oliList) {
                    consumed.add(new DataWrap(oli.Cota_Consumida__c, oli.Opportunity.Name, oli.OpportunityId, 
                                               oli.cantidadCotaConsumida__c, oli.Cota_Consumida__r.Name,
                                               oli.Cota_Consumida__r.segmento__r.Name, oli.Cota_Consumida__r.sub_canal__c, 
                                               oli.Cota_Consumida__r.regional__r.Name,oli.Cota_Consumida__r.bandeira__r.Name, 
                                               oli.Cota_Consumida__r.executivo__r.Name, oli.Cota_Consumida__r.executivo__c, oli.Opportunity.Account.Name,
                                               oli.Opportunity.AccountId, oli.Cota_Consumida__r.startDate__c, 
                                               oli.Cota_Consumida__r.endDate__c, oli.Cota_Consumida__r.cantidadDisponible__c,
                                               oli.Cota_Consumida__r.Cota__c, oli.Opportunity.CreatedDate,
                                               oli.Opportunity.OwnerId, oli.Opportunity.Owner.Name, oli.Opportunity.Account.Client_code_AN8__c,
                                               oli.Opportunity.NR_order_JDE__c, oli.Opportunity.Type));
                }                     
            }
        }
        //MIGRATED 03/11/2016        
        else {
                    List<LAT_CotaMarket__c> cotaList = [SELECT id, Name, totalCota__c, LAT_Product__r.Name, endDate__c, startDate__c,
                                                    InitDate__c, totalConsumido__c, totalDistribuido__c, 
                                                    (Select id FROM Detalhes_Cota__r) 
                                                FROM LAT_CotaMarket__c 
                                                WHERE id =: this.dummyLookup.cotaMarket__c];
        
            consumed.clear();
            if (!cotaList.isEmpty()) {
                filterCota = cotaList.get(0);
                List<String> detalhCotaIds = new List<String>();
                for (LAT_DetalheCotaMarket__c dcm : filterCota.Detalhes_Cota__r){
                    detalhCotaIds.add(dcm.id);
                }
                
                List<LAT_OpportunityLineItem__c> oliList = [SELECT id, LAT_Opportunity__c, LAT_ConsumedQuote__c, LAT_ConsumedQuote__r.Name, LAT_ConsumedQuote__r.segmento__r.Name, LAT_ConsumedQuote__r.sub_canal__c,
                                                             LAT_ConsumedQuote__r.regional__r.Name, LAT_ConsumedQuote__r.bandeira__r.Name, LAT_ConsumedQuote__r.cantidadDisponible__c,
                                                             LAT_ConsumedQuote__r.executivo__r.Name, LAT_ConsumedQuote__r.cliente__r.Name, LAT_ConsumedQuote__r.cliente__c, 
                                                             LAT_ConsumedQuote__r.startDate__c, LAT_ConsumedQuote__r.endDate__c, LAT_Opportunity__r.LAT_Account__r.Name, LAT_Opportunity__r.LAT_Account__c, 
                                                             LAT_ConsumedQuoteQuantity__c, LAT_Opportunity__r.Name, LAT_Opportunity__r.OwnerId, LAT_Opportunity__r.LAT_Account__r.Owner.Name, LAT_ConsumedQuote__r.Cota__c,
                                                             LAT_Opportunity__r.CreatedDate, LAT_Opportunity__r.LAT_Account__r.Client_code_AN8__c, LAT_Opportunity__r.LAT_NROrderJDE__c, LAT_Opportunity__r.LAT_Type__c
                                                        FROM LAT_OpportunityLineItem__c 
                                                        WHERE LAT_ConsumedQuote__c IN: detalhCotaIds ORDER BY LAT_Opportunity__r.Name];
                for (LAT_OpportunityLineItem__c oli: oliList) {
                    consumed.add(new DataWrap(oli.LAT_ConsumedQuote__c, oli.LAT_Opportunity__r.Name, oli.LAT_Opportunity__c, 
                                               oli.LAT_ConsumedQuoteQuantity__c, oli.LAT_ConsumedQuote__r.Name,
                                               oli.LAT_ConsumedQuote__r.segmento__r.Name, oli.LAT_ConsumedQuote__r.sub_canal__c, 
                                               oli.LAT_ConsumedQuote__r.regional__r.Name,oli.LAT_ConsumedQuote__r.bandeira__r.Name, 
                                               oli.LAT_ConsumedQuote__r.executivo__r.Name, oli.LAT_ConsumedQuote__r.executivo__c, oli.LAT_Opportunity__r.LAT_Account__r.Name,
                                               oli.LAT_Opportunity__r.LAT_Account__c, oli.LAT_ConsumedQuote__r.startDate__c, 
                                               oli.LAT_ConsumedQuote__r.endDate__c, oli.LAT_ConsumedQuote__r.cantidadDisponible__c,
                                               oli.LAT_ConsumedQuote__r.Cota__c, oli.LAT_Opportunity__r.CreatedDate,
                                               oli.LAT_Opportunity__r.OwnerId, oli.LAT_Opportunity__r.LAT_Account__r.Owner.Name, oli.LAT_Opportunity__r.LAT_Account__r.Client_code_AN8__c,
                                               oli.LAT_Opportunity__r.LAT_NROrderJDE__c, oli.LAT_Opportunity__r.LAT_Type__c));
                }    
            }
        }    
    }
    
    //Inner class for records table
    public class DataWrap {
        public string detalheId              {get;set;}
        public string Pedido                 {get;set;}
        public string oid                    {get;set;}
        public Decimal Consumo               {get;set;}
        public Decimal CotaRestante          {get;set;}
        public Decimal Cota                  {get;set;}
        public String DetalheName            {get;set;}
        public String Segmento               {get;set;}
        public String SubCanal               {get;set;}
        public String Regional               {get;set;}
        public String Bandeira               {get;set;}
        public String Executivo              {get;set;}
        public String ExecId                 {get;set;}
        public String ClienteId              {get;set;}
        public String Cliente                {get;set;}
        public Date   DataInicio             {get;set;}
        public Date   DataFim                {get;set;}
        public DateTime OrderDate            {get;set;}
        public String OrderOwnerId           {get;set;}
        public String OrderOwner             {get;set;}
        public String ClientAN8              {get;set;}
        public String OrderNJDE              {get;set;}
        public String OrderType              {get;set;}

        public DataWrap (string DetalheId, string Pedido, string Oid, Decimal Consumo, 
                         string DetalheName, string Segmento, string SubCanal, string Regional, 
                         string Bandeira, string Executivo, string ExecId, string Cliente, 
                         string ClienteId, date DataInicio, date DataFim, decimal CotaRestante, 
                         decimal Cota, dateTime OrderDate, string OrderOwnerId, string OrderOwner,
                         string ClientAN8, string OrderNJDE, string OrderType) {
            this.detalheId = DetalheId;
            this.Pedido = Pedido;
            this.oid = Oid;
            this.Consumo = Consumo;
            this.DetalheName = DetalheName;
            this.Segmento = Segmento;
            this.SubCanal = SubCanal;
            this.Regional = Regional;
            this.Bandeira = Bandeira;
            this.Executivo = Executivo;
            this.ExecId = ExecId;
            this.Cliente = Cliente;
            this.ClienteId = ClienteId;
            this.DataInicio = DataInicio;
            this.DataFim = DataFim;
            this.CotaRestante = CotaRestante;
            this.Cota = Cota;
            this.OrderDate = OrderDate;
            this.OrderOwnerId = OrderOwnerId;
            this.OrderOwner = OrderOwner;
            this.ClientAN8 = ClientAN8;
            this.OrderNJDE = OrderNJDE;
            this.OrderType = OrderType;
        }
    }
    
}