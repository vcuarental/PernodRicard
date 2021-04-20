/*************************************************************************************************
*                                         Company: ValueNet                                      * 
*------------------------------------------------------------------------------------------------*
*           Controlador del la Visualforce page LAT_BR_VFP07_PositivizationOfPDV                 *
**************************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
public with sharing class LAT_BR_VFC07_PositivizationOfPDVCtrl {
    
    //VARIABLES PUBLICAS
    public transient List<wrapReport> listWrapers {get;Set;}
    public transient List<wrapFilter> pdfFilters {get;Set;}
    public transient List<string> listYearMonth {get;Set;}
    public Planejamento__c planDesde {get;Set;}
    public Planejamento__c planHasta {get;Set;}
    public string rightOptionsHidden {get;Set;}
    public string leftOptionsHidden {get;Set;}
    public transient String reportName {get;set;}
    public Boolean hasAccess {get;Set;}
    public string renderAs {get;Set;}
    public transient Boolean ran {get;Set;}
    
    //Multipicklists
    public List<SelectOption> selectedRegional {get; Set;}
    public List<SelectOption> selectedBrand {get; Set;}
    public List<SelectOption> selectedCat {get; Set;}
    public List<SelectOption> allRegional {get; Set;}
    public List<SelectOption> allBrand {get; Set;}
    public List<SelectOption> allCat {get; Set;}
    
    //Estructura que se utiliza para la tabla del reporte
    public class wrapReport{
        public Map<string, Decimal> yearMonthValue {get;Set;}
        public Boolean firstBrand {get;Set;}
        public Boolean isPercent {get;Set;}
        public Boolean firstReg {get;Set;}
        public Boolean lastIndi {get;Set;}
        public string indicater {get;Set;}
        public string region {get;Set;}
        public string brand {get;Set;}
        wrapReport(string region, string brand, string indicater){
            this.firstReg = false;
            this.firstBrand = false;
            this.lastIndi = false;
            this.isPercent = false;
            this.region = region;
            this.brand = brand;
            this.indicater = indicater;
            this.yearMonthValue = new Map<string, Decimal>();
        }
    }
    
    //Estructura que se utiliza para la tabla de los filtros en caso de renderizar como PDF o Excel
    public class wrapFilter{
        public string categories {get;Set;}
        public string regional {get;Set;}
        public string brands {get;Set;}
        wrapFilter(){}
    }
    
    //VARIABLES PRIVADAS
    private static Map <string, integer> monthsByNames = new Map <string, integer>{'Janeiro' => 1, 'Fevereiro' => 2, 'Março' => 3, 'Abril' => 4, 'Maio' => 5, 'Junho' => 6, 'Julho' => 7, 'Agosto' => 8, 'Setembro' => 9, 'Outubro' => 10, 'Novembro' => 11, 'Dezembro' => 12};
    private static Map <integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
    private Id prodConc2RTId = Global_RecordTypeCache.getRtId('Produto_Concorr_ncia__c' + 'BRA_Standard');
    private Id visitaRTId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
    
    private Id produt2RTId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
    private Id LAT_produt2RTId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');

    private Map<string, Set<string>> mapCategoryBrands;
    private map<String, String> mapMonthPreviousMonth;
    private transient Map<String, Set<Id>> mapKeyPDD_ACTIVADO;
    private transient Map<String, Set<Id>> mapKeyPDD_NAOACTIVADO;
    private transient Map<String, Decimal> mapKeyVOL_PDD_ACTIVADO;
    private transient Map<String, Decimal> mapKeyVOL_PDD_NAOACTIVADO;
    private transient Map<String, Decimal> mapKeyVOL_PDD_ACTIVADOPrevious;
    private transient Map<String, Decimal> mapKeyVOL_PDD_NAOACTIVADOPrevious;
    
    //Constructor
    public LAT_BR_VFC07_PositivizationOfPDVCtrl() {
        if(!Utils.wasMigrationDone('1')) {        
        
            //Check de seguridad del reporte por medio del objeto LAT_CRP_Custom_Report__c  
            ran = false;
            hasAccess = false;
            string idFromReport = ApexPages.currentPage().getParameters().get('IdRep');
            
            LAT_CRP_Custom_Report__c crp;
            try{crp = [SELECT Id, LAT_VisualForceName__c, LAT_ReportName__c FROM LAT_CRP_Custom_Report__c WHERE id =: idFromReport];}catch(Exception e){}
            if(crp != null && crp.LAT_VisualForceName__c == 'LAT_BR_VFP07_PositivizationOfPDV'){
                hasAccess = true;
                reportName = crp.LAT_ReportName__c;
            }else{
                return;
            }
            
            //Inicializacion de variables
            mapMonthPreviousMonth = new map<String, String>();
            selectedRegional = new List<SelectOption>();
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
            
            //Carga de regiones
            for(Schema.PickListEntry region: Account.LAT_BR_RegionalClientOnPremise__c.getDescribe().getPickListValues()){
                allRegional.add(new SelectOption(region.getValue(),region.getLabel()));
            }
            allRegional.add(new SelectOption('Brasil', 'Brasil'));
            
            //Carga de Categorias y Marcas
            mapCategoryBrands = new Map<string, Set<string>>();
            
            List<AggregateResult> resultProds = [SELECT LAT_BR_BrandGrouping__c brand, LAT_BR_CategoryGrouping__c cat FROM Product2 WHERE LAT_BR_BrandGrouping__c !=null AND LAT_BR_CategoryGrouping__c != null AND RecordTypeId =: produt2RTId AND LAT_IsRefactorProduct__c='Y' GROUP BY LAT_BR_CategoryGrouping__c, LAT_BR_BrandGrouping__c];
            for(AggregateResult result: resultProds){
                String brand = String.ValueOf(result.get('brand'));
                String cat = String.ValueOf(result.get('cat'));
                if(mapCategoryBrands.containsKey(cat)){
                    mapCategoryBrands.get(cat).add(brand);
                }else{
                    mapCategoryBrands.put(cat, new Set<string>{brand});
                }
            }
            for(string cat: mapCategoryBrands.keySet()){
                allCat.add(new SelectOption(cat, cat));
            }
        }
        //MIGRATED 17/11/2016
        else {
            //Check de seguridad del reporte por medio del objeto LAT_CRP_Custom_Report__c  
            ran = false;
            hasAccess = false;
            string idFromReport = ApexPages.currentPage().getParameters().get('IdRep');
            
            LAT_CRP_Custom_Report__c crp;
            try{crp = [SELECT Id, LAT_VisualForceName__c, LAT_ReportName__c FROM LAT_CRP_Custom_Report__c WHERE id =: idFromReport];}catch(Exception e){}
            if(crp != null && crp.LAT_VisualForceName__c == 'LAT_BR_VFP07_PositivizationOfPDV'){
                hasAccess = true;
                reportName = crp.LAT_ReportName__c;
            }else{
                return;
            }
            
            //Inicializacion de variables
            mapMonthPreviousMonth = new map<String, String>();
            selectedRegional = new List<SelectOption>();
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
            
            //Carga de regiones
            for(Schema.PickListEntry region: Account.LAT_BR_RegionalClientOnPremise__c.getDescribe().getPickListValues()){
                allRegional.add(new SelectOption(region.getValue(),region.getLabel()));
            }
            allRegional.add(new SelectOption('Brasil', 'Brasil'));
            
            //Carga de Categorias y Marcas
            mapCategoryBrands = new Map<string, Set<string>>();
            
            List<AggregateResult> resultProds = [SELECT LAT_BR_BrandGrouping__c brand, LAT_BR_CategoryGrouping__c cat FROM LAT_Product__c WHERE LAT_BR_BrandGrouping__c !=null AND LAT_BR_CategoryGrouping__c != null AND RecordTypeId =: LAT_produt2RTId AND LAT_IsRefactorProduct__c='Y' GROUP BY LAT_BR_CategoryGrouping__c, LAT_BR_BrandGrouping__c];
            for(AggregateResult result: resultProds){
                String brand = String.ValueOf(result.get('brand'));
                String cat = String.ValueOf(result.get('cat'));
                if(mapCategoryBrands.containsKey(cat)){
                    mapCategoryBrands.get(cat).add(brand);
                }else{
                    mapCategoryBrands.put(cat, new Set<string>{brand});
                }
            }
            for(string cat: mapCategoryBrands.keySet()){
                allCat.add(new SelectOption(cat, cat));
            }            
        }
    }

    public PageReference doExecute(){
        if(!Utils.wasMigrationDone('1')) {
        
            //Validaciones de filtros
            if(selectedRegional.isEmpty() || selectedRegional == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00001));
                //LAT_BR_VFP03_00001 = Por favor, selecione a região para continuar
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
            
            //Generacion de filtros fecha
            integer fromMonth = monthsByNames.get(planDesde.M_s_de_Ref_rencia__c);
            integer toMonth = monthsByNames.get(planHasta.M_s_de_Ref_rencia__c);
            integer fromYear = integer.valueOf(planDesde.Ano_de_Referencia__c);
            integer toYear = integer.valueOf(planHasta.Ano_de_Referencia__c);
            Date fromDate = date.newinstance(fromYear, fromMonth, 1);
            Date toDate = date.newinstance(toYear, toMonth, 1);
            toDate = toDate.addMonths(1).addDays(-1);
            
            if(fromDate > toDate){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00006));
                //Label.LAT_BR_VFP03_00006 = A partir da data tem que ser mais velho do que a data
                return null;
            }
            if(fromdate.monthsbetween(todate) > 11){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00007));
                //Label.LAT_BR_VFP03_00007 = O relatório tem um alcance máximo de 12 meses
                return null;
            }
            
            //Armo la lista de meses para el query
            listYearMonth = new List<string>();
            date countDate = fromDate.addMonths(-1);
            date datePlusPrevious = countDate; 
            while(countDate <= toDate){
                mapMonthPreviousMonth.put(monthsByNum.get(countDate.month())+'/'+countDate.year(), monthsByNum.get(countDate.addMonths(-1).month())+'/'+countDate.addMonths(-1).year());
                listYearMonth.add(monthsByNum.get(countDate.month())+'/'+countDate.year());
                countDate = countDate.addMonths(1);
            }
            
            //Armo el set de regiones para el query
            Set<String> setOfRegions = new Set<String>();
            Set<String> setOfRegionsQuery = new Set<String>();
            for(SelectOption region: selectedRegional){
                setOfRegions.add(region.getValue());
                setOfRegionsQuery.add(region.getValue());
            }
            if(setOfRegions.contains('Brasil')){
                for(SelectOption region: allRegional){
                    setOfRegionsQuery.add(region.getValue());
                }
            }
            
            //Armo el set de marcas para el query
            Set<String> setOfBrands = new Set<String>();
            for(SelectOption brand: selectedBrand){
                setOfBrands.add(brand.getValue());
            }
            
            //SELECCIION INICIAL DE DATOS
            Set<Id> setIdContas = new Set<Id>();
            set<Date> setMonthYears = new set<Date>();
            
            List<AggregateResult> resultVisitas = [SELECT Planejamento__r.LAT_MonthYear__c monthYear,
                                                          Conta__c accountId,
                                                          Conta__r.LAT_BR_RegionalClientOnPremise__c region
                                                   FROM Visitas__c 
                                                   WHERE Conta__r.Channel__c = 'On Trade'
                                                   AND Conta__r.LAT_BR_RegionalClientOnPremise__c IN: setOfRegionsQuery
                                                   AND Planejamento__r.LAT_MonthYear__c >=: datePlusPrevious AND Planejamento__r.LAT_MonthYear__c <=: toDate
                                                   AND RecordTypeId =: visitaRTId
                                                   GROUP BY Planejamento__r.LAT_MonthYear__c, Conta__c, Conta__r.LAT_BR_RegionalClientOnPremise__c];
            
            for(AggregateResult result: resultVisitas){
                Date monthYear   = Date.ValueOf(result.get('monthYear'));
                String accountId = String.ValueOf(result.get('accountId'));
                setMonthYears.add(monthYear);
                setIdContas.add(accountId);
            }
            
            List<Gabarito_de_Execucao__c> resultGabaritos = [SELECT Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c,
                                                                    Checklist_de_Visita__r.Visita__r.Conta__c,
                                                                    Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c,
                                                                    Frequencia_1_unica_vez__c
                                                             FROM Gabarito_de_Execucao__c
                                                             WHERE Realizada_promocao_de_marcas_na_casa__c = true
                                                             AND Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklistGE__c = true
                                                             AND Checklist_de_Visita__r.Visita__r.RecordTypeId =: visitaRTId
                                                             AND Checklist_de_Visita__r.Visita__r.Conta__c IN: setIdContas
                                                             AND Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c IN: setMonthYears];
            
            //CREACION DE MAPAS
            mapKeyPDD_ACTIVADO = new Map<String, Set<Id>>();
            mapKeyPDD_NAOACTIVADO = new Map<String, Set<Id>>();
            mapKeyVOL_PDD_ACTIVADO = new Map<String, Decimal>();
            mapKeyVOL_PDD_NAOACTIVADO = new Map<String, Decimal>();
            mapKeyVOL_PDD_ACTIVADOPrevious = new Map<String, Decimal>();
            mapKeyVOL_PDD_NAOACTIVADOPrevious = new Map<String, Decimal>();
            
            //PDD ATIVADO
            for(Gabarito_de_Execucao__c gab: resultGabaritos){
                Date monthYear   = gab.Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c;
                String accountId = gab.Checklist_de_Visita__r.Visita__r.Conta__c;
                String region    = gab.Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c;
                String frec      = gab.Frequencia_1_unica_vez__c;
                
                if(frec != null){
                    for(String brandFrec: frec.split(';')){
                        if(setOfBrands.contains(brandFrec)){
                            string key = region+'-'+brandFrec+'-'+monthsByNum.get(monthYear.month())+'/'+monthYear.year();
                            //Agrego a PDD ATIVADO
                            addTo_PDD_ATIVADO(key, new set<Id>{accountId});
                        }
                    }
                }
            }
            
            resultGabaritos = null;
            
            //PDD NAO ATIVADO y VOLUMEN
            for(AggregateResult result: resultVisitas){
                Date monthYear   = Date.ValueOf(result.get('monthYear'));
                String accountId = String.ValueOf(result.get('accountId'));
                String region    = String.ValueOf(result.get('region'));
                
                for(String brand: setOfBrands){
                    string key = region+'-'+brand+'-'+monthsByNum.get(monthYear.month())+'/'+monthYear.year();
                    if(!(mapKeyPDD_ACTIVADO.containsKey(key) && mapKeyPDD_ACTIVADO.get(key).contains(accountId))){
                        //Agrego a PDD NAO ATIVADO
                        addTo_PDD_NAO_ATIVADO(key, new set<Id>{accountId});
                    }
                    //Agrego a los 2 Volumen PPD
                    addTo_VOL_PDD_ATIVADO(key, 0);
                    addTo_VOL_PDD_NAO_ATIVADO(key, 0);
                    addTo_VOL_PDD_ATIVADOPrevious(key, 0);
                    addTo_VOL_PDD_NAO_ATIVADOPrevious(key, 0);
                }
            }
            
           resultVisitas = null;
           
            
           Set<String> setKeysPPC = new Set<String>();
           for(String brand: setOfBrands){
               for(Date monthYear: setMonthYears){
                    for(Id idConta: setIdContas){
                        String keyPPC = '';
                        keyPPC += prodConc2RTId;
                        keyPPC += '|' + brand;
                        keyPPC += '|' + visitaRTId;
                        keyPPC += '|' + idConta;
                        keyPPC += '|' + monthYear;
                        setKeysPPC.add(keyPPC);
                    }
                }
            }
            
            setIdContas = null;
            
            if(!setKeysPPC.isEmpty()){
                List<Produto_Concorr_ncia__c> resultProdutosConc = [SELECT Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c, 
                                                                           Checklist_de_Visita__r.Visita__r.Conta__c,
                                                                           Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c, 
                                                                           Produto_PERNOD__r.LAT_BR_BrandGrouping__c, 
                                                                           Qtde_de_Caixas_Estoque__c
                                                                    FROM Produto_Concorr_ncia__c
                                                                    WHERE LAT_Key__c IN: setKeysPPC];
                                                                    
                setKeysPPC = null;
                                                                    
                /*
                List<Produto_Concorr_ncia__c> resultProdutosConc = [SELECT Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c, 
                                                                           Checklist_de_Visita__r.Visita__r.Conta__c,
                                                                           Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c, 
                                                                           Produto_PERNOD__r.LAT_BR_BrandGrouping__c, 
                                                                           Qtde_de_Caixas_Estoque__c
                                                                    FROM Produto_Concorr_ncia__c
                                                                    WHERE RecordTypeId =: prodConc2RTId
                                                                    AND Qtde_de_Caixas_Estoque__c > 0
                                                                    AND Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklist__c = true
                                                                    AND Produto_PERNOD__r.LAT_BR_BrandGrouping__c IN: setOfBrands
                                                                    AND Checklist_de_Visita__r.Visita__r.RecordTypeId =: visitaRTId
                                                                    AND Checklist_de_Visita__r.Visita__r.Conta__c IN: setIdContas
                                                                    AND Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c IN: setMonthYears];
               */
                //PDD VOL ATIVADO y PDD VOL NAO ATIVADO
                for(Produto_Concorr_ncia__c result: resultProdutosConc){
                    Date monthYear          = result.Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c;
                    String accountId        = result.Checklist_de_Visita__r.Visita__r.Conta__c;
                    String region           = result.Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c;
                    String prodBrand        = result.Produto_PERNOD__r.LAT_BR_BrandGrouping__c;
                    Decimal garrafasSellOut = result.Qtde_de_Caixas_Estoque__c;
                    
                    String key = region+'-'+prodBrand+'-'+monthsByNum.get(monthYear.month())+'/'+monthYear.year();
                    String keyNextMonth = region+'-'+prodBrand+'-'+monthsByNum.get(monthYear.addMonths(1).month())+'/'+monthYear.addMonths(1).year();
                    
                    //ATIVADO MES ACTUAL
                    if(mapKeyPDD_ACTIVADO.containsKey(key) && mapKeyPDD_ACTIVADO.get(key).contains(accountId)){
                        addTo_VOL_PDD_ATIVADO(key, garrafasSellOut);
                    }else if(mapKeyPDD_NAOACTIVADO.containsKey(key) && mapKeyPDD_NAOACTIVADO.get(key).contains(accountId)){
                        addTo_VOL_PDD_NAO_ATIVADO(key, garrafasSellOut);
                    }
                    
                    //ATIVADO MES PREVIO
                    if(mapKeyPDD_ACTIVADO.containsKey(keyNextMonth) && mapKeyPDD_ACTIVADO.get(keyNextMonth).contains(accountId)){
                        addTo_VOL_PDD_ATIVADOPrevious(key, garrafasSellOut);
                    }else if(mapKeyPDD_NAOACTIVADO.containsKey(keyNextMonth) && mapKeyPDD_NAOACTIVADO.get(keyNextMonth).contains(accountId)){
                        addTo_VOL_PDD_NAO_ATIVADOPrevious(key, garrafasSellOut);
                    }
                }
                
                resultProdutosConc = null;
                
                //Agrego Brasil si fue seleccionado
                if(setOfRegions.contains('Brasil')){
                    //Agrego Brasil a PPD ATIVADO
                    for(String keyMap: mapKeyPDD_ACTIVADO.keySet()){
                        List<String> keyForDash = keyMap.split('-');
                        String keyBR = 'Brasil-'+keyForDash[1]+'-'+keyForDash[2];
                        addTo_PDD_ATIVADO(keyBR, mapKeyPDD_ACTIVADO.get(keyMap));
                    }
                    //Agrego Brasil a PPD NAO ATIVADO
                    for(String keyMap: mapKeyPDD_NAOACTIVADO.keySet()){
                        List<String> keyForDash = keyMap.split('-');
                        String keyBR = 'Brasil-'+keyForDash[1]+'-'+keyForDash[2];
                        addTo_PDD_NAO_ATIVADO(keyBR, mapKeyPDD_NAOACTIVADO.get(keyMap));
                    }
                    //Agrego Brasil a VOL PPD ATIVADO
                    for(String keyMap: mapKeyVOL_PDD_ACTIVADO.keySet()){
                        List<String> keyForDash = keyMap.split('-');
                        String keyBR = 'Brasil-'+keyForDash[1]+'-'+keyForDash[2];
                        addTo_VOL_PDD_ATIVADO(keyBR, mapKeyVOL_PDD_ACTIVADO.get(keyMap));
                    }
                    //Agrego Brasil a VOL PPD NAO ATIVADO
                    for(String keyMap: mapKeyVOL_PDD_NAOACTIVADO.keySet()){
                        List<String> keyForDash = keyMap.split('-');
                        String keyBR = 'Brasil-'+keyForDash[1]+'-'+keyForDash[2];
                        addTo_VOL_PDD_NAO_ATIVADO(keyBR, mapKeyVOL_PDD_NAOACTIVADO.get(keyMap));
                    }
                }
                
                //COMPLETO EL WRAPPER
                List<String> indicaters = new List<String>{'PDD ATIVADO', 'Volume PDD ATIVADO', '% PDD ATIVADO', 'PDD Ñ ATIVADO', 'Volume PDD Ñ ATIVADO', '% PDD Ñ ATIVADO', 'ATIVADO x NÃO ATIVADO'};
                listWrapers = new List<wrapReport>();
                listYearMonth.remove(0);
                ran = true;
                for(String region : setOfRegions){
                    Boolean firstReg = true;
                    for(String brand : setOfBrands){
                        Boolean firstBrand = true;
                        for(string indi: indicaters){
                            wrapReport wp = new wrapReport(region, brand, indi);
                            for(string monthYear: listYearMonth){
                                if(firstBrand){
                                    wp.firstBrand = true;
                                    firstBrand = false;
                                    if(firstReg){
                                        wp.firstReg = true;
                                        firstReg = false;
                                    }
                                }
                                string key = region +'-'+ brand +'-'+ monthYear;
                                
                                wp.yearMonthValue.put(monthYear, 0);
                                if(indi == 'PDD ATIVADO'){
                                    if(mapKeyPDD_ACTIVADO.containsKey(key)){
                                        wp.yearMonthValue.put(monthYear, mapKeyPDD_ACTIVADO.get(key).size());
                                    }
                                }
                                if(indi == 'Volume PDD ATIVADO'){
                                    if(mapKeyVOL_PDD_ACTIVADO.containsKey(region+'-'+brand+'-'+monthYear)){
                                        wp.yearMonthValue.put(monthYear, mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear));
                                    }
                                }
                                if(indi == '% PDD ATIVADO'){
                                    wp.isPercent = true;
                                    Decimal value = 100;
                                    if(mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != 0 && mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != null && mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear) != null ){
                                        value = (1-(mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear)) / mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)))*(-100);
                                    }
                                    wp.yearMonthValue.put(monthYear, value);
                                }
                                if(indi == 'PDD Ñ ATIVADO'){
                                    if(mapKeyPDD_NAOACTIVADO.containsKey(key)){
                                        wp.yearMonthValue.put(monthYear, mapKeyPDD_NAOACTIVADO.get(key).size());
                                    }
                                }
                                if(indi == 'Volume PDD Ñ ATIVADO'){
                                    if(mapKeyVOL_PDD_NAOACTIVADO.containsKey(region+'-'+brand+'-'+monthYear)){
                                        wp.yearMonthValue.put(monthYear, mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear));
                                    }
                                }
                                if(indi == '% PDD Ñ ATIVADO'){
                                    wp.isPercent = true;
                                    Decimal value = 100;
                                    if(mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != 0 && mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != null && mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear) != null){
                                        value = (1-(mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear)) / mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)))*(-100);
                                    }
                                    wp.yearMonthValue.put(monthYear, value);
                                }
                                if(indi == 'ATIVADO x NÃO ATIVADO'){
                                    wp.lastIndi = true;
                                    wp.isPercent = true;
                                    Decimal valueActivated = 100;
                                    if(mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != 0 && mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != null && mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear) != null ){
                                        valueActivated = (1-(mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear)) / mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)))*(-100);
                                    }
                                    Decimal valueNotActivated = 100;
                                    if(mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != 0 && mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != null && mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear) != null){
                                        valueNotActivated = (1-(mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear)) / mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)))*(-100);
                                    }
                                    wp.yearMonthValue.put(monthYear, valueActivated - valueNotActivated);
                                }
                            }
                            listWrapers.add(wp);
                        }
                    }
                }
            }
            return null;
        }
        //MIGRATED 17/11/2016
        else {
            //Validaciones de filtros
            if(selectedRegional.isEmpty() || selectedRegional == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00001));
                //LAT_BR_VFP03_00001 = Por favor, selecione a região para continuar
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
            
            //Generacion de filtros fecha
            integer fromMonth = monthsByNames.get(planDesde.M_s_de_Ref_rencia__c);
            integer toMonth = monthsByNames.get(planHasta.M_s_de_Ref_rencia__c);
            integer fromYear = integer.valueOf(planDesde.Ano_de_Referencia__c);
            integer toYear = integer.valueOf(planHasta.Ano_de_Referencia__c);
            Date fromDate = date.newinstance(fromYear, fromMonth, 1);
            Date toDate = date.newinstance(toYear, toMonth, 1);
            toDate = toDate.addMonths(1).addDays(-1);
            
            if(fromDate > toDate){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00006));
                //Label.LAT_BR_VFP03_00006 = A partir da data tem que ser mais velho do que a data
                return null;
            }
            if(fromdate.monthsbetween(todate) > 11){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.LAT_BR_VFP03_00007));
                //Label.LAT_BR_VFP03_00007 = O relatório tem um alcance máximo de 12 meses
                return null;
            }
            
            //Armo la lista de meses para el query
            listYearMonth = new List<string>();
            date countDate = fromDate.addMonths(-1);
            date datePlusPrevious = countDate; 
            while(countDate <= toDate){
                mapMonthPreviousMonth.put(monthsByNum.get(countDate.month())+'/'+countDate.year(), monthsByNum.get(countDate.addMonths(-1).month())+'/'+countDate.addMonths(-1).year());
                listYearMonth.add(monthsByNum.get(countDate.month())+'/'+countDate.year());
                countDate = countDate.addMonths(1);
            }
            
            //Armo el set de regiones para el query
            Set<String> setOfRegions = new Set<String>();
            Set<String> setOfRegionsQuery = new Set<String>();
            for(SelectOption region: selectedRegional){
                setOfRegions.add(region.getValue());
                setOfRegionsQuery.add(region.getValue());
            }
            if(setOfRegions.contains('Brasil')){
                for(SelectOption region: allRegional){
                    setOfRegionsQuery.add(region.getValue());
                }
            }
            
            //Armo el set de marcas para el query
            Set<String> setOfBrands = new Set<String>();
            for(SelectOption brand: selectedBrand){
                setOfBrands.add(brand.getValue());
            }
            
            //SELECCIION INICIAL DE DATOS
            Set<Id> setIdContas = new Set<Id>();
            set<Date> setMonthYears = new set<Date>();
            
            List<AggregateResult> resultVisitas = [SELECT Planejamento__r.LAT_MonthYear__c monthYear,
                                                          Conta__c accountId,
                                                          Conta__r.LAT_BR_RegionalClientOnPremise__c region
                                                   FROM Visitas__c 
                                                   WHERE Conta__r.Channel__c = 'On Trade'
                                                   AND Conta__r.LAT_BR_RegionalClientOnPremise__c IN: setOfRegionsQuery
                                                   AND Planejamento__r.LAT_MonthYear__c >=: datePlusPrevious AND Planejamento__r.LAT_MonthYear__c <=: toDate
                                                   AND RecordTypeId =: visitaRTId
                                                   GROUP BY Planejamento__r.LAT_MonthYear__c, Conta__c, Conta__r.LAT_BR_RegionalClientOnPremise__c];
            
            for(AggregateResult result: resultVisitas){
                Date monthYear   = Date.ValueOf(result.get('monthYear'));
                String accountId = String.ValueOf(result.get('accountId'));
                setMonthYears.add(monthYear);
                setIdContas.add(accountId);
            }
            
            List<Gabarito_de_Execucao__c> resultGabaritos = [SELECT Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c,
                                                                    Checklist_de_Visita__r.Visita__r.Conta__c,
                                                                    Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c,
                                                                    Frequencia_1_unica_vez__c
                                                             FROM Gabarito_de_Execucao__c
                                                             WHERE Realizada_promocao_de_marcas_na_casa__c = true
                                                             AND Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklistGE__c = true
                                                             AND Checklist_de_Visita__r.Visita__r.RecordTypeId =: visitaRTId
                                                             AND Checklist_de_Visita__r.Visita__r.Conta__c IN: setIdContas
                                                             AND Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c IN: setMonthYears];
            
            //CREACION DE MAPAS
            mapKeyPDD_ACTIVADO = new Map<String, Set<Id>>();
            mapKeyPDD_NAOACTIVADO = new Map<String, Set<Id>>();
            mapKeyVOL_PDD_ACTIVADO = new Map<String, Decimal>();
            mapKeyVOL_PDD_NAOACTIVADO = new Map<String, Decimal>();
            mapKeyVOL_PDD_ACTIVADOPrevious = new Map<String, Decimal>();
            mapKeyVOL_PDD_NAOACTIVADOPrevious = new Map<String, Decimal>();
            
            //PDD ATIVADO
            for(Gabarito_de_Execucao__c gab: resultGabaritos){
                Date monthYear   = gab.Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c;
                String accountId = gab.Checklist_de_Visita__r.Visita__r.Conta__c;
                String region    = gab.Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c;
                String frec      = gab.Frequencia_1_unica_vez__c;
                
                if(frec != null){
                    for(String brandFrec: frec.split(';')){
                        if(setOfBrands.contains(brandFrec)){
                            string key = region+'-'+brandFrec+'-'+monthsByNum.get(monthYear.month())+'/'+monthYear.year();
                            //Agrego a PDD ATIVADO
                            addTo_PDD_ATIVADO(key, new set<Id>{accountId});
                        }
                    }
                }
            }
            
            resultGabaritos = null;
            
            //PDD NAO ATIVADO y VOLUMEN
            for(AggregateResult result: resultVisitas){
                Date monthYear   = Date.ValueOf(result.get('monthYear'));
                String accountId = String.ValueOf(result.get('accountId'));
                String region    = String.ValueOf(result.get('region'));
                
                for(String brand: setOfBrands){
                    string key = region+'-'+brand+'-'+monthsByNum.get(monthYear.month())+'/'+monthYear.year();
                    if(!(mapKeyPDD_ACTIVADO.containsKey(key) && mapKeyPDD_ACTIVADO.get(key).contains(accountId))){
                        //Agrego a PDD NAO ATIVADO
                        addTo_PDD_NAO_ATIVADO(key, new set<Id>{accountId});
                    }
                    //Agrego a los 2 Volumen PPD
                    addTo_VOL_PDD_ATIVADO(key, 0);
                    addTo_VOL_PDD_NAO_ATIVADO(key, 0);
                    addTo_VOL_PDD_ATIVADOPrevious(key, 0);
                    addTo_VOL_PDD_NAO_ATIVADOPrevious(key, 0);
                }
            }
            
           resultVisitas = null;
           
            
           Set<String> setKeysPPC = new Set<String>();
           for(String brand: setOfBrands){
               for(Date monthYear: setMonthYears){
                    for(Id idConta: setIdContas){
                        String keyPPC = '';
                        keyPPC += prodConc2RTId;
                        keyPPC += '|' + brand;
                        keyPPC += '|' + visitaRTId;
                        keyPPC += '|' + idConta;
                        keyPPC += '|' + monthYear;
                        setKeysPPC.add(keyPPC);
                    }
                }
            }
            
            setIdContas = null;
            
            if(!setKeysPPC.isEmpty()){
                List<Produto_Concorr_ncia__c> resultProdutosConc = [SELECT Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c, 
                                                                           Checklist_de_Visita__r.Visita__r.Conta__c,
                                                                           Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c, 
                                                                           LAT_Product__r.LAT_BR_BrandGrouping__c, 
                                                                           Qtde_de_Caixas_Estoque__c
                                                                    FROM Produto_Concorr_ncia__c
                                                                    WHERE LAT_Key__c IN: setKeysPPC];
                                                                    
                setKeysPPC = null;
                                                                    
                /*
                List<Produto_Concorr_ncia__c> resultProdutosConc = [SELECT Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c, 
                                                                           Checklist_de_Visita__r.Visita__r.Conta__c,
                                                                           Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c, 
                                                                           Produto_PERNOD__r.LAT_BR_BrandGrouping__c, 
                                                                           Qtde_de_Caixas_Estoque__c
                                                                    FROM Produto_Concorr_ncia__c
                                                                    WHERE RecordTypeId =: prodConc2RTId
                                                                    AND Qtde_de_Caixas_Estoque__c > 0
                                                                    AND Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklist__c = true
                                                                    AND Produto_PERNOD__r.LAT_BR_BrandGrouping__c IN: setOfBrands
                                                                    AND Checklist_de_Visita__r.Visita__r.RecordTypeId =: visitaRTId
                                                                    AND Checklist_de_Visita__r.Visita__r.Conta__c IN: setIdContas
                                                                    AND Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c IN: setMonthYears];
               */
                //PDD VOL ATIVADO y PDD VOL NAO ATIVADO
                for(Produto_Concorr_ncia__c result: resultProdutosConc){
                    Date monthYear          = result.Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c;
                    String accountId        = result.Checklist_de_Visita__r.Visita__r.Conta__c;
                    String region           = result.Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c;
                    String prodBrand        = result.LAT_Product__r.LAT_BR_BrandGrouping__c;
                    Decimal garrafasSellOut = result.Qtde_de_Caixas_Estoque__c;
                    
                    String key = region+'-'+prodBrand+'-'+monthsByNum.get(monthYear.month())+'/'+monthYear.year();
                    String keyNextMonth = region+'-'+prodBrand+'-'+monthsByNum.get(monthYear.addMonths(1).month())+'/'+monthYear.addMonths(1).year();
                    
                    //ATIVADO MES ACTUAL
                    if(mapKeyPDD_ACTIVADO.containsKey(key) && mapKeyPDD_ACTIVADO.get(key).contains(accountId)){
                        addTo_VOL_PDD_ATIVADO(key, garrafasSellOut);
                    }else if(mapKeyPDD_NAOACTIVADO.containsKey(key) && mapKeyPDD_NAOACTIVADO.get(key).contains(accountId)){
                        addTo_VOL_PDD_NAO_ATIVADO(key, garrafasSellOut);
                    }
                    
                    //ATIVADO MES PREVIO
                    if(mapKeyPDD_ACTIVADO.containsKey(keyNextMonth) && mapKeyPDD_ACTIVADO.get(keyNextMonth).contains(accountId)){
                        addTo_VOL_PDD_ATIVADOPrevious(key, garrafasSellOut);
                    }else if(mapKeyPDD_NAOACTIVADO.containsKey(keyNextMonth) && mapKeyPDD_NAOACTIVADO.get(keyNextMonth).contains(accountId)){
                        addTo_VOL_PDD_NAO_ATIVADOPrevious(key, garrafasSellOut);
                    }
                }
                
                resultProdutosConc = null;
                
                //Agrego Brasil si fue seleccionado
                if(setOfRegions.contains('Brasil')){
                    //Agrego Brasil a PPD ATIVADO
                    for(String keyMap: mapKeyPDD_ACTIVADO.keySet()){
                        List<String> keyForDash = keyMap.split('-');
                        String keyBR = 'Brasil-'+keyForDash[1]+'-'+keyForDash[2];
                        addTo_PDD_ATIVADO(keyBR, mapKeyPDD_ACTIVADO.get(keyMap));
                    }
                    //Agrego Brasil a PPD NAO ATIVADO
                    for(String keyMap: mapKeyPDD_NAOACTIVADO.keySet()){
                        List<String> keyForDash = keyMap.split('-');
                        String keyBR = 'Brasil-'+keyForDash[1]+'-'+keyForDash[2];
                        addTo_PDD_NAO_ATIVADO(keyBR, mapKeyPDD_NAOACTIVADO.get(keyMap));
                    }
                    //Agrego Brasil a VOL PPD ATIVADO
                    for(String keyMap: mapKeyVOL_PDD_ACTIVADO.keySet()){
                        List<String> keyForDash = keyMap.split('-');
                        String keyBR = 'Brasil-'+keyForDash[1]+'-'+keyForDash[2];
                        addTo_VOL_PDD_ATIVADO(keyBR, mapKeyVOL_PDD_ACTIVADO.get(keyMap));
                    }
                    //Agrego Brasil a VOL PPD NAO ATIVADO
                    for(String keyMap: mapKeyVOL_PDD_NAOACTIVADO.keySet()){
                        List<String> keyForDash = keyMap.split('-');
                        String keyBR = 'Brasil-'+keyForDash[1]+'-'+keyForDash[2];
                        addTo_VOL_PDD_NAO_ATIVADO(keyBR, mapKeyVOL_PDD_NAOACTIVADO.get(keyMap));
                    }
                }
                
                //COMPLETO EL WRAPPER
                List<String> indicaters = new List<String>{'PDD ATIVADO', 'Volume PDD ATIVADO', '% PDD ATIVADO', 'PDD Ñ ATIVADO', 'Volume PDD Ñ ATIVADO', '% PDD Ñ ATIVADO', 'ATIVADO x NÃO ATIVADO'};
                listWrapers = new List<wrapReport>();
                listYearMonth.remove(0);
                ran = true;
                for(String region : setOfRegions){
                    Boolean firstReg = true;
                    for(String brand : setOfBrands){
                        Boolean firstBrand = true;
                        for(string indi: indicaters){
                            wrapReport wp = new wrapReport(region, brand, indi);
                            for(string monthYear: listYearMonth){
                                if(firstBrand){
                                    wp.firstBrand = true;
                                    firstBrand = false;
                                    if(firstReg){
                                        wp.firstReg = true;
                                        firstReg = false;
                                    }
                                }
                                string key = region +'-'+ brand +'-'+ monthYear;
                                
                                wp.yearMonthValue.put(monthYear, 0);
                                if(indi == 'PDD ATIVADO'){
                                    if(mapKeyPDD_ACTIVADO.containsKey(key)){
                                        wp.yearMonthValue.put(monthYear, mapKeyPDD_ACTIVADO.get(key).size());
                                    }
                                }
                                if(indi == 'Volume PDD ATIVADO'){
                                    if(mapKeyVOL_PDD_ACTIVADO.containsKey(region+'-'+brand+'-'+monthYear)){
                                        wp.yearMonthValue.put(monthYear, mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear));
                                    }
                                }
                                if(indi == '% PDD ATIVADO'){
                                    wp.isPercent = true;
                                    Decimal value = 100;
                                    if(mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != 0 && mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != null && mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear) != null ){
                                        value = (1-(mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear)) / mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)))*(-100);
                                    }
                                    wp.yearMonthValue.put(monthYear, value);
                                }
                                if(indi == 'PDD Ñ ATIVADO'){
                                    if(mapKeyPDD_NAOACTIVADO.containsKey(key)){
                                        wp.yearMonthValue.put(monthYear, mapKeyPDD_NAOACTIVADO.get(key).size());
                                    }
                                }
                                if(indi == 'Volume PDD Ñ ATIVADO'){
                                    if(mapKeyVOL_PDD_NAOACTIVADO.containsKey(region+'-'+brand+'-'+monthYear)){
                                        wp.yearMonthValue.put(monthYear, mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear));
                                    }
                                }
                                if(indi == '% PDD Ñ ATIVADO'){
                                    wp.isPercent = true;
                                    Decimal value = 100;
                                    if(mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != 0 && mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != null && mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear) != null){
                                        value = (1-(mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear)) / mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)))*(-100);
                                    }
                                    wp.yearMonthValue.put(monthYear, value);
                                }
                                if(indi == 'ATIVADO x NÃO ATIVADO'){
                                    wp.lastIndi = true;
                                    wp.isPercent = true;
                                    Decimal valueActivated = 100;
                                    if(mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != 0 && mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != null && mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear) != null ){
                                        valueActivated = (1-(mapKeyVOL_PDD_ACTIVADO.get(region+'-'+brand+'-'+monthYear)) / mapKeyVOL_PDD_ACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)))*(-100);
                                    }
                                    Decimal valueNotActivated = 100;
                                    if(mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != 0 && mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)) != null && mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear) != null){
                                        valueNotActivated = (1-(mapKeyVOL_PDD_NAOACTIVADO.get(region+'-'+brand+'-'+monthYear)) / mapKeyVOL_PDD_NAOACTIVADOPrevious.get(region+'-'+brand+'-'+mapMonthPreviousMonth.get(monthYear)))*(-100);
                                    }
                                    wp.yearMonthValue.put(monthYear, valueActivated - valueNotActivated);
                                }
                            }
                            listWrapers.add(wp);
                        }
                    }
                }
            }
            return null;            
        }
    }
    
    //Metodo para agregar un Account a PDD ATIVADO
    private void addTo_PDD_ATIVADO(String key, Set<Id> setAccountId){
        if(mapKeyPDD_ACTIVADO.containsKey(key)){
            mapKeyPDD_ACTIVADO.get(key).addAll(setAccountId);
        }else{
            mapKeyPDD_ACTIVADO.put(key, setAccountId);
        }
    }
    
    //Metodo para agregar un Account a PDD NAO ATIVADO
    private void addTo_PDD_NAO_ATIVADO(String key, Set<Id> setAccountId){
        if(mapKeyPDD_NAOACTIVADO.containsKey(key)){
            mapKeyPDD_NAOACTIVADO.get(key).addAll(setAccountId);
        }else{
            mapKeyPDD_NAOACTIVADO.put(key, setAccountId);
        }
    }
    
    //Metodo para agregar un volumen de garrafasSellOut a VOL PDD ATIVADO
    private void addTo_VOL_PDD_ATIVADO(String key, Decimal garrafasSellOut){
        if(!mapKeyVOL_PDD_ACTIVADO.containsKey(key)) {
            mapKeyVOL_PDD_ACTIVADO.put(key, 0);
        }
        //mapKeyVOL_PDD_ACTIVADO.get(key) += garrafasSellOut;
        /*Decimal aux = mapKeyVOL_PDD_ACTIVADO.get(key) + garrafasSellOut;
        mapKeyVOL_PDD_ACTIVADO.put(key, aux);    */  
        mapKeyVOL_PDD_ACTIVADO.put(key, mapKeyVOL_PDD_ACTIVADO.get(key) + garrafasSellOut); 
    }

    //Metodo para agregar un volumen de garrafasSellOut a VOL PDD ATIVADO Previo
    private void addTo_VOL_PDD_ATIVADOPrevious(String key, Decimal garrafasSellOut){
        if(!mapKeyVOL_PDD_ACTIVADOPrevious.containsKey(key)) {
            mapKeyVOL_PDD_ACTIVADOPrevious.put(key, 0);
        }          
        //mapKeyVOL_PDD_ACTIVADOPrevious.get(key) += garrafasSellOut;
        /*Decimal aux = mapKeyVOL_PDD_ACTIVADOPrevious.get(key) + garrafasSellOut;
        mapKeyVOL_PDD_ACTIVADOPrevious.put(key, aux); */
        mapKeyVOL_PDD_ACTIVADOPrevious.put(key, mapKeyVOL_PDD_ACTIVADOPrevious.get(key) + garrafasSellOut);
    }
    
    //Metodo para agregar un volumen de garrafasSellOut a VOL PDD NAO ATIVADO
    private void addTo_VOL_PDD_NAO_ATIVADO(String key, Decimal garrafasSellOut){
        if(!mapKeyVOL_PDD_NAOACTIVADO.containsKey(key)) {
            mapKeyVOL_PDD_NAOACTIVADO.put(key, 0);
        }          
        //mapKeyVOL_PDD_NAOACTIVADO.get(key) += garrafasSellOut;
        /*Decimal aux = mapKeyVOL_PDD_NAOACTIVADO.get(key) + garrafasSellOut;
        mapKeyVOL_PDD_NAOACTIVADO.put(key, aux);  */ 
        mapKeyVOL_PDD_NAOACTIVADO.put(key, mapKeyVOL_PDD_NAOACTIVADO.get(key) + garrafasSellOut);
    }
    
    //Metodo para agregar un volumen de garrafasSellOut a VOL PDD NAO ATIVADO Previo
    private void addTo_VOL_PDD_NAO_ATIVADOPrevious(String key, Decimal garrafasSellOut){        
        if(!mapKeyVOL_PDD_NAOACTIVADOPrevious.containsKey(key)) {
            mapKeyVOL_PDD_NAOACTIVADOPrevious.put(key, 0);
        }          
        //mapKeyVOL_PDD_NAOACTIVADOPrevious.get(key) += garrafasSellOut;
        /*Decimal aux = mapKeyVOL_PDD_NAOACTIVADOPrevious.get(key) + garrafasSellOut;
        mapKeyVOL_PDD_NAOACTIVADOPrevious.put(key, aux);   */   
        mapKeyVOL_PDD_NAOACTIVADOPrevious.put(key, mapKeyVOL_PDD_NAOACTIVADOPrevious.get(key) + garrafasSellOut);                      
    }
        
    //Metodo para agregar una categoria a los filtros
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
    
    //Metodo para remover una categoria de los filtros
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
    
    //Metodo que recalcula las Marcas segun las Categorias
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
    
    //Metodo para renderizar el reporte como PDF
    public pageReference doExportPDF(){
        loadFilters();
        renderAs = 'pdf';
        return null;
    }
    
    //Metodo para renderizar el reporte como Excel
    public pageReference doExportExcel(){
        loadFilters();
        renderAs = 'excel';
        return null;
    }
    
    //Metodo para mostrar los filtros seleccionados cuando se hace el renderizado a PDF o Excel
    private void loadFilters(){
        pdfFilters = new List<wrapFilter>();
        List<Integer> listSizes = new List<Integer>{selectedCat.size(), selectedBrand.size(), selectedRegional.size()};
        listSizes.sort();
        for(Integer i=0; i<listSizes[2]; i++){
            wrapFilter wf = new wrapFilter();
            try{wf.regional = selectedRegional[i].getValue();}catch(Exception e){}
            try{wf.categories = selectedCat[i].getValue();}catch(Exception e){}
            try{wf.brands = selectedBrand[i].getValue();}catch(Exception e){}
            pdfFilters.add(wf);
        }
    }
    
    //Metodo para tomar el color del Tab "Custom Reports" y utilizarlo en la tabla del reporte
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
        //Default Color "Light Green"
        return '#b4c374';
    }
}