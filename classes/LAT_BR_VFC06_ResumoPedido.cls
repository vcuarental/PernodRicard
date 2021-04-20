/********************************************************************
* Company: Valuenet 
* Desarrollador: Nicolas J. Romero
* Nombre del pagina: LAT_BR_VFP06_ResumoPedido
* Descripcion: extencion de la pagina LAT_BR_VFP06_ResumoPedido
* Fecha: 19/12/2013 
*********************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 03/11/2016
*
********************************************************************************/

public class LAT_BR_VFC06_ResumoPedido {
    
    public Opportunity opp {get;set;}
    public Account acc {get;set;}
    public List<OpportunityLineItem> listOli {get;set;}
    public string renderAs {get;set;}
    public OpportunityLineItem oliTotal {get;set;}
    public double totalQuan {get;set;}
    public double totalQTBonus {get;set;}
    public double totalQtTotal {get;set;}
    public String sOlis {get;set;}
    public String priceSim {get;set;}
    public String dateToday {get;set;}

    //Variables Migracion Licencias
    public LAT_Opportunity__c LAT_opp {get;set;}
    public List<LAT_OpportunityLineItem__c> LAT_listOli {get;set;} 
    public LAT_OpportunityLineItem__c LAT_oliTotal {get;set;}


    private string oppId;
    
    public LAT_BR_VFC06_ResumoPedido(){

        if(!Utils.wasMigrationDone('1')) {
            dateToday =  datetime.now().day() < 10 ? ('0'+datetime.now().day()) : (''+datetime.now().day());
            dateToday += '-';
            dateToday += datetime.now().month() < 10 ? ('0'+datetime.now().month()) : (''+datetime.now().month());
            dateToday += '-';
            dateToday += String.ValueOf(datetime.now().year());
            dateToday += ' ';
            dateToday += datetime.now().hour() < 10 ? ('0'+datetime.now().hour()) : (''+datetime.now().hour());
            dateToday += ':';
            dateToday += datetime.now().minute() < 10 ? ('0'+datetime.now().minute()) : (''+datetime.now().minute());
            dateToday += ':';
            dateToday += datetime.now().second() < 10 ? ('0'+datetime.now().second()) : (''+datetime.now().second());
            
            renderAs = '';
            
            oliTotal = new OpportunityLineItem();
            
            totalQuan = 0;
            totalQTBonus = 0;
            totalQtTotal = 0;
            oliTotal.LAT_NFValue__c = 0;
    		oliTotal.LAT_IPI__c = 0;
    		oliTotal.LAT_TaxReplacement__c = 0;
    		oliTotal.LAT_NFTotal__c = 0;
            
            oppId = system.currentPageReference().getParameters().get('oppId');
            try{acc = [SELECT Id, Client_code_AN8__c, Name, CurrencyISOCode FROM Account WHERE Id =: system.currentPageReference().getParameters().get('accId')];}catch(Exception e){}
            priceSim = system.currentPageReference().getParameters().get('priceSim');
            
            if(oppId != null && oppId != '') {
                try{
                    opp = [SELECT Id, Name, NR_order_JDE__c, NR_customer_order__c, CurrencyIsoCode, Codigo_do_cliente_AN8__c, Account.Name FROM Opportunity WHERE Id =: oppId][0];
                }catch(Exception e){
                    Apexpages.addMessage( new Apexpages.Message( Apexpages.SEVERITY.ERROR, Label.LAT_BR_VFP06_00001));
                    return;
                }
                
                listOli = [SELECT Id, PriceBookEntry.Product2.SKU__c, PriceBookEntry.Product2.Name, PriceBookEntry.Product2.CD_Unit__c, LAT_NFValue__c, Campo_de_formatacao__c , LAT_IPI__c, LAT_TaxReplacement__c, LAT_NFTotal__c, LAT_PaymentConditionDescription__c, Quantity, QT_Bonus__c, Qt_total__c 
                           FROM OpportunityLineItem 
                           WHERE OpportunityId =: oppId];
                
                oliTotal.Opportunity = opp; 
                
                calculateTotals();
            } else if (priceSim != '1') {
                Apexpages.addMessage( new Apexpages.Message( Apexpages.SEVERITY.ERROR, Label.LAT_BR_VFP06_00001));
                //Label.LAT_BR_VFP06_00001 = Parameters are null.
                return;
            }                                        
        
        }
        //MIGRATED 03/11/2016 
        else {
            dateToday =  datetime.now().day() < 10 ? ('0'+datetime.now().day()) : (''+datetime.now().day());
            dateToday += '-';
            dateToday += datetime.now().month() < 10 ? ('0'+datetime.now().month()) : (''+datetime.now().month());
            dateToday += '-';
            dateToday += String.ValueOf(datetime.now().year());
            dateToday += ' ';
            dateToday += datetime.now().hour() < 10 ? ('0'+datetime.now().hour()) : (''+datetime.now().hour());
            dateToday += ':';
            dateToday += datetime.now().minute() < 10 ? ('0'+datetime.now().minute()) : (''+datetime.now().minute());
            dateToday += ':';
            dateToday += datetime.now().second() < 10 ? ('0'+datetime.now().second()) : (''+datetime.now().second());
            
            renderAs = '';
            
            LAT_oliTotal = new LAT_OpportunityLineItem__c();
            
            totalQuan = 0;
            totalQTBonus = 0;
            totalQtTotal = 0;
            LAT_oliTotal.LAT_NFValue__c = 0;
            LAT_oliTotal.LAT_IPI__c = 0;
            LAT_oliTotal.LAT_TaxReplacement__c = 0;
            LAT_oliTotal.LAT_NFTotal__c = 0;
            
            oppId = system.currentPageReference().getParameters().get('oppId');
            try{acc = [SELECT Id, Client_code_AN8__c, Name, CurrencyISOCode FROM Account WHERE Id =: system.currentPageReference().getParameters().get('accId')];}catch(Exception e){}
            priceSim = system.currentPageReference().getParameters().get('priceSim');
            
            if(oppId != null && oppId != '') {
                try{
                    LAT_opp = [SELECT Id, Name, LAT_NROrderJDE__c, LAT_NRCustomerOrder__c, CurrencyIsoCode, LAT_ClientCodeAN8__c, LAT_Account__r.Name FROM LAT_Opportunity__c WHERE Id =: oppId][0];
                }catch(Exception e){
                    Apexpages.addMessage( new Apexpages.Message( Apexpages.SEVERITY.ERROR, Label.LAT_BR_VFP06_00001));
                    return;
                }
                
                LAT_listOli = [SELECT Id, LAT_Product__r.LAT_Sku__c, LAT_Product__r.Name, LAT_Product__r.LAT_CDUnit__c, LAT_NFValue__c, LAT_FormatField__c , LAT_IPI__c, LAT_TaxReplacement__c, LAT_NFTotal__c, LAT_PaymentConditionDescription__c, LAT_Quantity__c, LAT_QTBonus__c, LAT_QTTotal__c 
                           FROM LAT_OpportunityLineItem__c 
                           WHERE LAT_Opportunity__c =: oppId];
                
                LAT_oliTotal.LAT_Opportunity__c = LAT_opp.Id; 
                
                calculateTotals();
            } else if (priceSim != '1') {
                Apexpages.addMessage( new Apexpages.Message( Apexpages.SEVERITY.ERROR, Label.LAT_BR_VFP06_00001));
                //Label.LAT_BR_VFP06_00001 = Parameters are null.
                return;
            } 
        }
    }
    
    public void renderTable(){
        if(!Utils.wasMigrationDone('1')) {
            List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
            try{olis = (List<OpportunityLineItem>)JSON.deserialize(sOlis, List<OpportunityLineItem>.class);}catch(Exception e){}
            if(!olis.isEmpty()){
                listOli = new List<OpportunityLineItem>();
                listOli.addAll(olis);
                
                map<Id, PricebookEntry> mapIdPBE = new map<Id, PricebookEntry>();
                for(OpportunityLineItem oli: listOli){
                    mapIdPBE.put(oli.PricebookEntryId, oli.PricebookEntry);
                }
                for(PricebookEntry pbe: [SELECT Product2.Name, Product2.CD_Unit__c, Product2.Sku__c FROM PricebookEntry WHERE Id IN: mapIdPBE.keySet()]){
                    mapIdPBE.put(pbe.Id, pbe);
                }
                for(OpportunityLineItem oli: listOli){
                    oli.PricebookEntry = mapIdPBE.get(oli.PricebookEntryId);
                }
                calculateTotals();
            }
        } 
        //MIGRATED 03/11/2016
        else {
            List<LAT_OpportunityLineItem__c> olis = new List<LAT_OpportunityLineItem__c>();
            try{olis = (List<LAT_OpportunityLineItem__c>)JSON.deserialize(sOlis, List<LAT_OpportunityLineItem__c>.class);}catch(Exception e){}
            if(!olis.isEmpty()){
                LAT_listOli = new List<LAT_OpportunityLineItem__c>();
                LAT_listOli.addAll(olis);
                
                calculateTotals();
            }            
        }
    }
    
    private void calculateTotals(){
        if(!Utils.wasMigrationDone('1')){
            LAT_BR_AP01_OpportunityLineItem.decodeCompositionPrice(listOli);
            for(OpportunityLineItem oliadd: listOli) {
                if(oliadd.Quantity != null){
                    totalQuan += oliadd.Quantity;
                }
                if(oliadd.QT_Bonus__c != null){
                    totalQTBonus += oliadd.QT_Bonus__c;
                }
                if(oliadd.Qt_total__c != null){
                    totalQtTotal += oliadd.Qt_total__c;
                }
                if(oliadd.LAT_NFValue__c != null){
                    oliTotal.LAT_NFValue__c += oliadd.LAT_NFValue__c;
                }
                if(oliadd.LAT_IPI__c != null){
                    oliTotal.LAT_IPI__c += oliadd.LAT_IPI__c;
                }
                if(oliadd.LAT_TaxReplacement__c != null){
                    oliTotal.LAT_TaxReplacement__c += oliadd.LAT_TaxReplacement__c;
                }
                if(oliadd.LAT_NFTotal__c != null){
                    oliTotal.LAT_NFTotal__c += oliadd.LAT_NFTotal__c;
                }
            }
        } 
        //MIGRATED 03/11/2016
        else {          
            LAT_BR_AP01_OpportunityLineItem.decodeCompositionPrice(LAT_listOli);
            for(LAT_OpportunityLineItem__c oliadd: LAT_listOli) {
                if(oliadd.LAT_Quantity__c != null){
                    totalQuan += oliadd.LAT_Quantity__c;
                }
                if(oliadd.LAT_QTBonus__c != null){
                    totalQTBonus += oliadd.LAT_QTBonus__c;
                }
                if(oliadd.LAT_QTTotal__c != null){
                    totalQtTotal += oliadd.LAT_QTTotal__c;
                }
                if(oliadd.LAT_NFValue__c != null){
                    LAT_oliTotal.LAT_NFValue__c += oliadd.LAT_NFValue__c;
                }
                if(oliadd.LAT_IPI__c != null){
                    LAT_oliTotal.LAT_IPI__c += oliadd.LAT_IPI__c;
                }
                if(oliadd.LAT_TaxReplacement__c != null){
                    LAT_oliTotal.LAT_TaxReplacement__c += oliadd.LAT_TaxReplacement__c;
                }
                if(oliadd.LAT_NFTotal__c != null){
                    LAT_oliTotal.LAT_NFTotal__c += oliadd.LAT_NFTotal__c;
                }
            }
        }
    }
    
    public void exportToExcel(){
        renderAs = 'excel';
    }
    public void exportToPDF(){
        renderAs = 'pdf';
    }
    
}