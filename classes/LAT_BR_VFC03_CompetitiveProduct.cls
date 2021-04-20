/*************************************************************************************************
*                                         Company: ValueNet                                      *
*------------------------------------------------------------------------------------------------*
*           Controlador del la Visualforce page LAT_BR_VFP03_CompetitiveProduct                  *
**************************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_VFC03_CompetitiveProduct {
    
    private static Map <string, integer> monthsByNames = new Map <string, integer>{'Janeiro' => 1, 'Fevereiro' => 2, 'Março' => 3, 'Abril' => 4, 'Maio' => 5, 'Junho' => 6, 'Julho' => 7, 'Agosto' => 8, 'Setembro' => 9, 'Outubro' => 10, 'Novembro' => 11, 'Dezembro' => 12};
    private static Map <integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
    public Map<string, Set<string>> mapCategoryBrands {get; Set;}
    public List<SelectOption> selectedSegmentacion {get; Set;}
    public List<SelectOption> selectedRegional {get; Set;}
    public List<SelectOption> allSegmentacion {get; Set;}
    public List<SelectOption> selectedBrand {get; Set;}
    public List<SelectOption> selectedCat {get; Set;}
    public List<SelectOption> allRegional {get; Set;}
    public List<wrapReport> listWrapers {get;Set;}
    public List<SelectOption> allBrand {get; Set;}
    public List<wrapFilter> pdfFilters {get;Set;}
    public List<SelectOption> allCat {get; Set;}
    public Planejamento__c planDesde {get;Set;}
    public Planejamento__c planHasta {get;Set;}
    public string rightOptionsHidden {get;Set;}
    public List<string> listAnioMes {get;Set;}
    public string leftOptionsHidden {get;Set;}
    public String reportName {get;set;}
    public Boolean hasAccess {get;Set;}
    public string renderAs {get;Set;}
    public Boolean ran {get;Set;}
    
    //Estructura que se utiliza para la tabla del reporte
    public class wrapReport{
        public string region {get;Set;}
        public string segmento {get;Set;}
        public string marca {get;Set;}
        public Boolean firstReg {get;Set;}
        public Boolean firstSeg {get;Set;}
        public Map<string, integer> anioMesValor {get;Set;}
        wrapReport(string region, string segmento, string marca){
            this.region = region;
            this.segmento = segmento;
            this.marca = marca;
            this.anioMesValor = new Map<string, integer>();
            this.firstReg = false;
            this.firstSeg = false;
        }
    }
    
    //Estructura que se utiliza para la tabla de los filtros en caso de renderizar como PDF o Excel
    public class wrapFilter{
        public string region {get;Set;}
        public string segmento {get;Set;}
        public string categoria {get;Set;}
        public string marca {get;Set;}
        wrapFilter(){}
    }
    
    public LAT_BR_VFC03_CompetitiveProduct() {
        if(!Utils.wasMigrationDone('1')) {        
            ran = false;
            hasAccess = false;
            string idFromReport = ApexPages.currentPage().getParameters().get('IdRep');
            
            LAT_CRP_Custom_Report__c crp;
            try{crp = [SELECT Id, LAT_VisualForceName__c, LAT_ReportName__c FROM LAT_CRP_Custom_Report__c WHERE id =: idFromReport];}catch(Exception e){}
            if(crp != null && crp.LAT_VisualForceName__c == 'LAT_BR_VFP03_CompetitiveProduct'){
                hasAccess = true;
                reportName = crp.LAT_ReportName__c;
            }else{
                return;
            }
            
            selectedSegmentacion = new List<SelectOption>();
            selectedRegional = new List<SelectOption>();
            allSegmentacion = new List<SelectOption>();
            selectedBrand = new List<SelectOption>();
            selectedCat = new List<SelectOption>();
            allRegional = new List<SelectOption>();
            allBrand = new List<SelectOption>();
            allCat = new List<SelectOption>();
            planDesde = new Planejamento__c();
            planHasta = new Planejamento__c();
            
            planDesde.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().addMonths(-6).month()); 
            planDesde.Ano_de_Referencia__c = string.ValueOf(date.today().addMonths(-6).year()); 
            planHasta.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().month());
            planHasta.Ano_de_Referencia__c = string.ValueOf(date.today().year());
            
            for(Schema.PickListEntry reg: Account.LAT_BR_RegionalClientOnPremise__c.getDescribe().getPickListValues()){
                allRegional.add(new SelectOption(reg.getValue(),reg.getLabel()));
            }
            allRegional.add(new SelectOption('Brasil', 'Brasil'));
            
            for(LAT_BR_CS001_Segmentacion__c seg: [SELECT Id, Name FROM LAT_BR_CS001_Segmentacion__c]){
                allSegmentacion.add(new SelectOption(seg.Name,seg.Name));
            }
            
            String rtOffBrProd2 = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
            
            mapCategoryBrands = new Map<string, Set<string>>();
            for(Product2 prod: [SELECT id, Name, LAT_BR_BrandGrouping__c, LAT_BR_CategoryGrouping__c FROM Product2 WHERE LAT_BR_BrandGrouping__c !=null AND LAT_BR_CategoryGrouping__c != null AND RecordTypeId =: rtOffBrProd2 AND LAT_IsRefactorProduct__c='Y']){
                if(mapCategoryBrands.containsKey(prod.LAT_BR_CategoryGrouping__c)){
                    mapCategoryBrands.get(prod.LAT_BR_CategoryGrouping__c).add(prod.LAT_BR_BrandGrouping__c);
                }else{
                    mapCategoryBrands.put(prod.LAT_BR_CategoryGrouping__c, new Set<string>{prod.LAT_BR_BrandGrouping__c});
                }
            }
            
            for(string cat: mapCategoryBrands.keySet()){
                allCat.add(new SelectOption(cat, cat));
            }
        }
        //MIGRATED 17/11/2016
        else {
            ran = false;
            hasAccess = false;
            string idFromReport = ApexPages.currentPage().getParameters().get('IdRep');
            
            LAT_CRP_Custom_Report__c crp;
            try{crp = [SELECT Id, LAT_VisualForceName__c, LAT_ReportName__c FROM LAT_CRP_Custom_Report__c WHERE id =: idFromReport];}catch(Exception e){}
            if(crp != null && crp.LAT_VisualForceName__c == 'LAT_BR_VFP03_CompetitiveProduct'){
                hasAccess = true;
                reportName = crp.LAT_ReportName__c;
            }else{
                return;
            }
            
            selectedSegmentacion = new List<SelectOption>();
            selectedRegional = new List<SelectOption>();
            allSegmentacion = new List<SelectOption>();
            selectedBrand = new List<SelectOption>();
            selectedCat = new List<SelectOption>();
            allRegional = new List<SelectOption>();
            allBrand = new List<SelectOption>();
            allCat = new List<SelectOption>();
            planDesde = new Planejamento__c();
            planHasta = new Planejamento__c();
            
            planDesde.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().addMonths(-6).month()); 
            planDesde.Ano_de_Referencia__c = string.ValueOf(date.today().addMonths(-6).year()); 
            planHasta.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().month());
            planHasta.Ano_de_Referencia__c = string.ValueOf(date.today().year());
            
            for(Schema.PickListEntry reg: Account.LAT_BR_RegionalClientOnPremise__c.getDescribe().getPickListValues()){
                allRegional.add(new SelectOption(reg.getValue(),reg.getLabel()));
            }
            allRegional.add(new SelectOption('Brasil', 'Brasil'));
            
            for(LAT_BR_CS001_Segmentacion__c seg: [SELECT Id, Name FROM LAT_BR_CS001_Segmentacion__c]){
                allSegmentacion.add(new SelectOption(seg.Name,seg.Name));
            }
            
            String rtOffBrProd2 = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
            
            mapCategoryBrands = new Map<string, Set<string>>();
            for(LAT_Product__c prod: [SELECT id, Name, LAT_BR_BrandGrouping__c, LAT_BR_CategoryGrouping__c FROM LAT_Product__c WHERE LAT_BR_BrandGrouping__c !=null AND LAT_BR_CategoryGrouping__c != null AND RecordTypeId =: rtOffBrProd2 AND LAT_IsRefactorProduct__c='Y']){
                if(mapCategoryBrands.containsKey(prod.LAT_BR_CategoryGrouping__c)){
                    mapCategoryBrands.get(prod.LAT_BR_CategoryGrouping__c).add(prod.LAT_BR_BrandGrouping__c);
                }else{
                    mapCategoryBrands.put(prod.LAT_BR_CategoryGrouping__c, new Set<string>{prod.LAT_BR_BrandGrouping__c});
                }
            }
            
            for(string cat: mapCategoryBrands.keySet()){
                allCat.add(new SelectOption(cat, cat));
            }            
        }
    }

    public PageReference Ejecutar() {
        if(!Utils.wasMigrationDone('1')) {       
            listWrapers = new List<wrapReport>();
            
            if(selectedRegional.isEmpty() || selectedRegional == null ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00001));
                //LAT_BR_VFP03_00001 = Por favor, selecione a região para continuar
                return null;
            }
            if(selectedSegmentacion.isEmpty() || selectedSegmentacion == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00002));
                //LAT_BR_VFP03_00002 = Por favor seleccione um segmentacion para continuar
                return null;
            }
            if(selectedCat.isEmpty() || selectedCat == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00003));
                //LAT_BR_VFP03_00003 = Por favor seleccione uma categoria para continuar
                return null;
            }
            if(selectedBrand.isEmpty() || selectedBrand == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00004));
                //LAT_BR_VFP03_00004 = Por favor, selecione uma marca para continuar
                return null;
            }
            if(planDesde.M_s_de_Ref_rencia__c == null || planDesde.Ano_de_Referencia__c == null || planHasta.M_s_de_Ref_rencia__c == null || planHasta.Ano_de_Referencia__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00005));
                //LAT_BR_VFP03_00005 = Por favor, preencha as datas para continuar
                return null;
            }
            
            integer fromMonth = monthsByNames.get(planDesde.M_s_de_Ref_rencia__c);
            integer fromYear = integer.valueOf(planDesde.Ano_de_Referencia__c);
            integer toMonth = monthsByNames.get(planHasta.M_s_de_Ref_rencia__c);
            integer toYear = integer.valueOf(planHasta.Ano_de_Referencia__c);
            Date fromDate = date.newinstance(fromYear, fromMonth, 1);
            Date toDate = date.newinstance(toYear, toMonth, 1);
            
            if(fromDate > toDate){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00006));
                //LAT_BR_VFP03_00006 = A partir da data tem que ser mais velho do que a data
                return null;
            }
            if(fromdate.monthsbetween(todate) > 11){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00007));
                //LAT_BR_VFP03_00007 = O relatório tem um alcance máximo de 12 meses
                return null;
            }
            
            //Validacion de seleccionados vacios
            listAnioMes = new List<string>();
            date countDate = fromDate;
            while(countDate <= toDate){
                listAnioMes.add(monthsByNum.get(countDate.month())+'/'+countDate.year());
                countDate = countDate.addMonths(1);
            }
            
            //Hago un set de las regiones y segmentaciones seleccionadas
            set<String> selectedReg = new set<String>();
            for(SelectOption region : selectedRegional){
            	selectedReg.add(region.getValue());
            }
            set<String> selectedSeg = new set<String>();
            for(SelectOption segmentacion : selectedSegmentacion){
            	selectedSeg.add(segmentacion.getValue());
            }
            
            Map<string, Set<Id>> mapRegSegMesAnioCantCli = new Map<string, Set<Id>>();
            set<String> clientesForDebug = new set<String>();
            
            set<Id> setIdRt = Global_RecordTypeCache.getRtIdSet('Account',new set<String>{'On_Trade', 'Off_Trade', 'Eventos'});
            for(Visitas__c vis: [SELECT Id, Conta__c, Conta__r.Name, Conta__r.LAT_BR_RegionalClientOnPremise__c, Conta__r.Rating_segmentation_targert_market__c, Planejamento__r.LAT_MonthYear__c 
            				  FROM Visitas__c
            				  WHERE Conta__r.Channel__c = 'On Trade' AND Conta__r.Status__c != 'Cliente inativo' AND Conta__r.LAT_BR_RegionalClientOnPremise__c IN: selectedReg AND Conta__r.Rating_segmentation_targert_market__c IN: selectedSeg AND Conta__r.RecordTypeId IN: setIdRt AND Planejamento__r.LAT_MonthYear__c >=: fromDate AND Planejamento__r.LAT_MonthYear__c <=: toDate]){
            	
            	string reg = vis.Conta__r.LAT_BR_RegionalClientOnPremise__c;
                string seg = vis.Conta__r.Rating_segmentation_targert_market__c;
            	string dat = monthsByNum.get(vis.Planejamento__r.LAT_MonthYear__c.month())+'/'+vis.Planejamento__r.LAT_MonthYear__c.year();
            	
            	//Calculamos cantidad de cliente por region y segmentacion
                if(!mapRegSegMesAnioCantCli.containsKey(reg+'-'+seg+'-'+dat)){
                    mapRegSegMesAnioCantCli.put(reg+'-'+seg+'-'+dat, new Set<Id>{vis.Conta__c});
                }else{
                    mapRegSegMesAnioCantCli.get(reg+'-'+seg+'-'+dat).add(vis.Conta__c);
                }
                //Calculamos cantidad de cliente para Brasil
                if(!mapRegSegMesAnioCantCli.containsKey('Brasil-'+seg+'-'+dat)){
                    mapRegSegMesAnioCantCli.put('Brasil-'+seg+'-'+dat, new Set<Id>{vis.Conta__c});
                }else{
                    mapRegSegMesAnioCantCli.get('Brasil-'+seg+'-'+dat).add(vis.Conta__c);
                }
                clientesForDebug.add(vis.Conta__r.Name);
            }
            
            List<Produto_Concorr_ncia__c> proConList = [SELECT Id, Name, CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c, CheckList_de_visita__r.Visita__r.Conta__r.Name, CheckList_de_visita__r.Visita__r.Conta__c, Qtde_de_Caixas_Estoque__c, Nao_se_aplica__c, CheckList_de_visita__r.LAT_BR_ValidOnTradeCheckList__c, CheckList_de_visita__r.Visita__r.Conta__r.Channel__c, CheckList_de_visita__r.Visita__r.Conta__r.Status__c, CheckList_de_visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c, Produto_PERNOD__r.LAT_BR_BrandGrouping__c, Produto_PERNOD__r.LAT_BR_CategoryGrouping__c, CheckList_de_visita__r.Visita__r.Conta__r.Rating_segmentation_targert_market__c
                                                        FROM Produto_Concorr_ncia__c
                                                        WHERE CheckList_de_visita__r.Visita__r.Conta__r.Channel__c = 'On Trade'
                                                        AND CheckList_de_visita__r.Visita__r.Conta__r.Status__c != 'Cliente inativo'
                                                        AND CheckList_de_visita__r.LAT_BR_ValidOnTradeCheckList__c =: true
                                                        AND (Qtde_de_Caixas_Estoque__c >: 0 OR Nao_se_aplica__c =: true)
                                                        AND CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c >=: fromDate 
                                                        AND CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c <=: toDate];
            
            //Proceso para llenar los mapas
            Map<string, List<string>> mapRegSegBraDateCantBran = new Map<string, List<string>>();
            set<Id> prodsConcorrentesForDebug = new set<Id>();
            set<Id> checkListsForDebug = new set<Id>();
            
            for(Produto_Concorr_ncia__c proCon: proConList){
                string reg = proCon.CheckList_de_visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c;
                string seg = proCon.CheckList_de_visita__r.Visita__r.Conta__r.Rating_segmentation_targert_market__c;
                string bra = proCon.Produto_PERNOD__r.LAT_BR_BrandGrouping__c;
                string dat = monthsByNum.get(proCon.CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c.month())+'/'+proCon.CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c.year();
                
                //Calculamos cantidad de productos de una marca por region, segmentacion y mes/anio
                if(!mapRegSegBraDateCantBran.containskey(reg+'-'+seg+'-'+bra+'-'+dat)){
                    mapRegSegBraDateCantBran.put(reg+'-'+seg+'-'+bra+'-'+dat, new List<string>{bra});
                }else{
                    mapRegSegBraDateCantBran.get(reg+'-'+seg+'-'+bra+'-'+dat).add(bra);
                }
                //Calculamos cantidad de productos de una marca para Brasil, segmentacion y mes/anio
                if(!mapRegSegBraDateCantBran.containskey('Brasil-'+seg+'-'+bra+'-'+dat)){
                    mapRegSegBraDateCantBran.put('Brasil-'+seg+'-'+bra+'-'+dat, new List<string>{bra});
                }else{
                    mapRegSegBraDateCantBran.get('Brasil-'+seg+'-'+bra+'-'+dat).add(bra);
                }
                checkListsForDebug.add(proCon.CheckList_de_visita__c);
                prodsConcorrentesForDebug.add(proCon.Id);
            }
            
            ran = true;
            for(SelectOption region : selectedRegional){
                Boolean firstReg = true;
                for(SelectOption segmentacion : selectedSegmentacion){
                    Boolean firstSeg = true;
                    for(SelectOption marca : selectedBrand){
                        wrapReport wp = new wrapReport(region.getValue(), segmentacion.getValue(), marca.getValue());
                        if(firstReg){
                            wp.firstReg = true;
                            firstReg = false;
                        }
                        if(firstSeg){
                            wp.firstSeg = true;
                            firstSeg = false;
                        }
                        for(string anioMes: listAnioMes){
                            Integer cantCli = 0;
                            Integer cantBra = 0;
                            
                            string keyCli = region.getValue() +'-'+ segmentacion.getValue()+'-'+ anioMes;
                            if(mapRegSegMesAnioCantCli.containskey(keyCli)){
                                cantCli = mapRegSegMesAnioCantCli.get(keyCli).size();
                            }
                            string keyBra = region.getValue() +'-'+ segmentacion.getValue()+'-'+marca.getValue()+'-'+ anioMes;
                            if(mapRegSegBraDateCantBran.containsKey(keyBra)){
                                cantBra = mapRegSegBraDateCantBran.get(keyBra).size();
                            }
                            
                            decimal value = 0;
                            
                            if(cantCli != 0 && cantBra != 0){
                                 value = Decimal.ValueOf(cantBra).divide(cantCli, 2);
                                 value = value * 100;
                            }
                            wp.anioMesValor.put(anioMes, value.intValue());
                        }
                        listWrapers.add(wp);
                    }
                }
            }
            return null;
        }
        //MIGRATED 17/11/2016
        else {
            listWrapers = new List<wrapReport>();
            
            if(selectedRegional.isEmpty() || selectedRegional == null ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00001));
                //LAT_BR_VFP03_00001 = Por favor, selecione a região para continuar
                return null;
            }
            if(selectedSegmentacion.isEmpty() || selectedSegmentacion == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00002));
                //LAT_BR_VFP03_00002 = Por favor seleccione um segmentacion para continuar
                return null;
            }
            if(selectedCat.isEmpty() || selectedCat == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00003));
                //LAT_BR_VFP03_00003 = Por favor seleccione uma categoria para continuar
                return null;
            }
            if(selectedBrand.isEmpty() || selectedBrand == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00004));
                //LAT_BR_VFP03_00004 = Por favor, selecione uma marca para continuar
                return null;
            }
            if(planDesde.M_s_de_Ref_rencia__c == null || planDesde.Ano_de_Referencia__c == null || planHasta.M_s_de_Ref_rencia__c == null || planHasta.Ano_de_Referencia__c == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00005));
                //LAT_BR_VFP03_00005 = Por favor, preencha as datas para continuar
                return null;
            }
            
            integer fromMonth = monthsByNames.get(planDesde.M_s_de_Ref_rencia__c);
            integer fromYear = integer.valueOf(planDesde.Ano_de_Referencia__c);
            integer toMonth = monthsByNames.get(planHasta.M_s_de_Ref_rencia__c);
            integer toYear = integer.valueOf(planHasta.Ano_de_Referencia__c);
            Date fromDate = date.newinstance(fromYear, fromMonth, 1);
            Date toDate = date.newinstance(toYear, toMonth, 1);
            
            if(fromDate > toDate){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00006));
                //LAT_BR_VFP03_00006 = A partir da data tem que ser mais velho do que a data
                return null;
            }
            if(fromdate.monthsbetween(todate) > 11){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00007));
                //LAT_BR_VFP03_00007 = O relatório tem um alcance máximo de 12 meses
                return null;
            }
            
            //Validacion de seleccionados vacios
            listAnioMes = new List<string>();
            date countDate = fromDate;
            while(countDate <= toDate){
                listAnioMes.add(monthsByNum.get(countDate.month())+'/'+countDate.year());
                countDate = countDate.addMonths(1);
            }
            
            //Hago un set de las regiones y segmentaciones seleccionadas
            set<String> selectedReg = new set<String>();
            for(SelectOption region : selectedRegional){
                selectedReg.add(region.getValue());
            }
            set<String> selectedSeg = new set<String>();
            for(SelectOption segmentacion : selectedSegmentacion){
                selectedSeg.add(segmentacion.getValue());
            }
            
            Map<string, Set<Id>> mapRegSegMesAnioCantCli = new Map<string, Set<Id>>();
            set<String> clientesForDebug = new set<String>();
            
            set<Id> setIdRt = Global_RecordTypeCache.getRtIdSet('Account',new set<String>{'On_Trade', 'Off_Trade', 'Eventos'});
            for(Visitas__c vis: [SELECT Id, Conta__c, Conta__r.Name, Conta__r.LAT_BR_RegionalClientOnPremise__c, 
                                Conta__r.Rating_segmentation_targert_market__c, Planejamento__r.LAT_MonthYear__c 
                              FROM Visitas__c
                              WHERE Conta__r.Channel__c = 'On Trade' AND Conta__r.Status__c != 'Cliente inativo' 
                              AND Conta__r.LAT_BR_RegionalClientOnPremise__c IN: selectedReg
                               AND Conta__r.Rating_segmentation_targert_market__c IN: selectedSeg AND Conta__r.RecordTypeId
                                IN: setIdRt AND Planejamento__r.LAT_MonthYear__c >=: fromDate
                                 AND Planejamento__r.LAT_MonthYear__c <=: toDate]){
                
                string reg = vis.Conta__r.LAT_BR_RegionalClientOnPremise__c;
                string seg = vis.Conta__r.Rating_segmentation_targert_market__c;
                string dat = monthsByNum.get(vis.Planejamento__r.LAT_MonthYear__c.month())+'/'+vis.Planejamento__r.LAT_MonthYear__c.year();
                
                //Calculamos cantidad de cliente por region y segmentacion
                if(!mapRegSegMesAnioCantCli.containsKey(reg+'-'+seg+'-'+dat)){
                    mapRegSegMesAnioCantCli.put(reg+'-'+seg+'-'+dat, new Set<Id>{vis.Conta__c});
                }else{
                    mapRegSegMesAnioCantCli.get(reg+'-'+seg+'-'+dat).add(vis.Conta__c);
                }
                //Calculamos cantidad de cliente para Brasil
                if(!mapRegSegMesAnioCantCli.containsKey('Brasil-'+seg+'-'+dat)){
                    mapRegSegMesAnioCantCli.put('Brasil-'+seg+'-'+dat, new Set<Id>{vis.Conta__c});
                }else{
                    mapRegSegMesAnioCantCli.get('Brasil-'+seg+'-'+dat).add(vis.Conta__c);
                }
                clientesForDebug.add(vis.Conta__r.Name);
            }
            
            List<Produto_Concorr_ncia__c> proConList = [SELECT Id, Name, CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c, 
                                                CheckList_de_visita__r.Visita__r.Conta__r.Name, CheckList_de_visita__r.Visita__r.Conta__c, 
                                                Qtde_de_Caixas_Estoque__c, Nao_se_aplica__c, CheckList_de_visita__r.LAT_BR_ValidOnTradeCheckList__c,
                                                CheckList_de_visita__r.Visita__r.Conta__r.Channel__c, CheckList_de_visita__r.Visita__r.Conta__r.Status__c, 
                                                CheckList_de_visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c, LAT_Product__r.LAT_BR_BrandGrouping__c,
                                                LAT_Product__r.LAT_BR_CategoryGrouping__c, CheckList_de_visita__r.Visita__r.Conta__r.Rating_segmentation_targert_market__c
                                                FROM Produto_Concorr_ncia__c
                                                WHERE CheckList_de_visita__r.Visita__r.Conta__r.Channel__c = 'On Trade'
                                                AND CheckList_de_visita__r.Visita__r.Conta__r.Status__c != 'Cliente inativo'
                                                AND CheckList_de_visita__r.LAT_BR_ValidOnTradeCheckList__c =: true
                                                AND (Qtde_de_Caixas_Estoque__c >: 0 OR Nao_se_aplica__c =: true)
                                                AND CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c >=: fromDate 
                                                AND CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c <=: toDate];
            
            //Proceso para llenar los mapas
            Map<string, List<string>> mapRegSegBraDateCantBran = new Map<string, List<string>>();
            set<Id> prodsConcorrentesForDebug = new set<Id>();
            set<Id> checkListsForDebug = new set<Id>();
            
            for(Produto_Concorr_ncia__c proCon: proConList){
                string reg = proCon.CheckList_de_visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c;
                string seg = proCon.CheckList_de_visita__r.Visita__r.Conta__r.Rating_segmentation_targert_market__c;
                string bra = proCon.LAT_Product__r.LAT_BR_BrandGrouping__c;
                string dat = monthsByNum.get(proCon.CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c.month())+'/'+proCon.CheckList_de_visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c.year();
                
                //Calculamos cantidad de productos de una marca por region, segmentacion y mes/anio
                if(!mapRegSegBraDateCantBran.containskey(reg+'-'+seg+'-'+bra+'-'+dat)){
                    mapRegSegBraDateCantBran.put(reg+'-'+seg+'-'+bra+'-'+dat, new List<string>{bra});
                }else{
                    mapRegSegBraDateCantBran.get(reg+'-'+seg+'-'+bra+'-'+dat).add(bra);
                }
                //Calculamos cantidad de productos de una marca para Brasil, segmentacion y mes/anio
                if(!mapRegSegBraDateCantBran.containskey('Brasil-'+seg+'-'+bra+'-'+dat)){
                    mapRegSegBraDateCantBran.put('Brasil-'+seg+'-'+bra+'-'+dat, new List<string>{bra});
                }else{
                    mapRegSegBraDateCantBran.get('Brasil-'+seg+'-'+bra+'-'+dat).add(bra);
                }
                checkListsForDebug.add(proCon.CheckList_de_visita__c);
                prodsConcorrentesForDebug.add(proCon.Id);
            }
            
            ran = true;
            for(SelectOption region : selectedRegional){
                Boolean firstReg = true;
                for(SelectOption segmentacion : selectedSegmentacion){
                    Boolean firstSeg = true;
                    for(SelectOption marca : selectedBrand){
                        wrapReport wp = new wrapReport(region.getValue(), segmentacion.getValue(), marca.getValue());
                        if(firstReg){
                            wp.firstReg = true;
                            firstReg = false;
                        }
                        if(firstSeg){
                            wp.firstSeg = true;
                            firstSeg = false;
                        }
                        for(string anioMes: listAnioMes){
                            Integer cantCli = 0;
                            Integer cantBra = 0;
                            
                            string keyCli = region.getValue() +'-'+ segmentacion.getValue()+'-'+ anioMes;
                            if(mapRegSegMesAnioCantCli.containskey(keyCli)){
                                cantCli = mapRegSegMesAnioCantCli.get(keyCli).size();
                            }
                            string keyBra = region.getValue() +'-'+ segmentacion.getValue()+'-'+marca.getValue()+'-'+ anioMes;
                            if(mapRegSegBraDateCantBran.containsKey(keyBra)){
                                cantBra = mapRegSegBraDateCantBran.get(keyBra).size();
                            }
                            
                            decimal value = 0;
                            
                            if(cantCli != 0 && cantBra != 0){
                                 value = Decimal.ValueOf(cantBra).divide(cantCli, 2);
                                 value = value * 100;
                            }
                            wp.anioMesValor.put(anioMes, value.intValue());
                        }
                        listWrapers.add(wp);
                    }
                }
            }
            return null;
        }
    }
    
    public PageReference doAddCategory(){
        Set<string> seleccionadas = new Set<string>();
        seleccionadas.addAll(leftOptionsHidden.split(',,,'));
        
        for(string str: seleccionadas){
            if(str!=null && str!=''){
                selectedCat.add(new selectoption(str,str));
            }
        }
        
        for(integer i=0; i<allCat.size(); i++){
            if(seleccionadas.contains(allCat[i].getValue())){
                allCat.remove(i); i--;
            }
        }
        reloadBrands();
        return null;
    }
    
    public PageReference doRemoveCategory(){
        Set<string> seleccionadas = new Set<string>();
        seleccionadas.addAll(rightOptionsHidden.split(',,,'));
        
        for(string str: seleccionadas){
            if(str!=null && str!=''){
                allCat.add(new selectoption(str,str));
            }
        }
        
        for(integer i=0;i<selectedCat.size();i++){
            if(seleccionadas.contains(selectedCat[i].getValue())){
                selectedCat.remove(i); i--;
            }
        }
        reloadBrands();
        return null;
    }
    
    private void reloadBrands(){
        //Armo el Set de marcas habilitadas para todas las categorias seleccionadas
        Set<string> setAvailableBrands = new Set<string>();
        for(selectoption sel: selectedCat){
            if(mapCategoryBrands.containskey(sel.getvalue())){
                for(string val: mapCategoryBrands.get(sel.getvalue())){
                    setAvailableBrands.add(val);
                }
            }
        }
        
        //Quito de la lista de marcas seleccionadas las que estén afuera de las habilitadas
        for(integer i=0; i< selectedBrand.size(); i++){
            if(!setAvailableBrands.contains(selectedBrand[i].getvalue())){
                selectedBrand.remove(i); i--;
            }
        }
        
        //Armo un Set de las marcas seleccionadas
        Set<string> setSelectedBrands = new Set<string>();
        for(selectoption sel: selectedBrand){
            setSelectedBrands.add(sel.getValue());
        }
        
        //Borro la lista de marcas disponibles y agrego todas las que no estén en seleccionadas
        allBrand = new List<SelectOption>();
        for(string val: setAvailableBrands){
            if((!setSelectedBrands.contains(val))){
                allBrand.add(new selectoption(val, val));
            }
        }
    }
    
    public pageReference doExportPDF(){
        loadFilters();
        renderAs = 'pdf';
        return null;
    }
    
    public pageReference doExportExcel(){
        loadFilters();
        renderAs = 'excel';
        return null;
    }
    
    private void loadFilters(){
        pdfFilters = new List<wrapFilter>();
        
        List<Integer> listSizes = new List<Integer>{selectedRegional.size(), selectedSegmentacion.size(), selectedCat.size(), selectedBrand.size()};
        listSizes.sort();
        
        for(Integer i=0; i<listSizes[3]; i++){
            wrapFilter wf = new wrapFilter();
            try{wf.region = selectedRegional[i].getValue();}catch(Exception e){}
            try{wf.segmento = selectedSegmentacion[i].getValue();}catch(Exception e){}
            try{wf.categoria= selectedCat[i].getValue();}catch(Exception e){}
            try{wf.marca = selectedBrand[i].getValue();}catch(Exception e){}
            pdfFilters.add(wf);
        }
    }
    
    public string getColorTab(){
		for(DescribeTabSetResult tsr : Schema.describeTabs()) {
		    for(Schema.DescribeTabResult tr : tsr.getTabs()) {
		        if(tr.getLabel() == 'Custom Reports'){
		            for(Schema.DescribeColorResult dc: tr.getColors()){
		                return '#'+dc.getColor();
		            }
		    	}
		    }            
		}
		//Default Color
		return '#b4c374';
    }
}