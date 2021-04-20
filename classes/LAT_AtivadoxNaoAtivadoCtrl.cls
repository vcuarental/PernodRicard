/*************************************************************************************************
*                                    Company: Zimmic                                             * 
*------------------------------------------------------------------------------------------------*
*              Controlador del la Visualforce page LAT_BR_VFP12_PositivizationReport4            *
**************************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/

global without sharing class LAT_AtivadoxNaoAtivadoCtrl {
    
    //VARIABLES PUBLICAS
    public List<wrapReportRow> listWrapersNew {get;Set;}
    public List<wrapFilter> pdfFilters {get;Set;}
    public List<string> listYearMonth {get;Set;}
    public Planejamento__c planDesde {get;Set;}
    public Planejamento__c planHasta {get;Set;}
    public string rightOptionsHidden {get;Set;}
    public string leftOptionsHidden {get;Set;}
    public String reportName {get;set;}
    public Boolean hasAccess {get;Set;}
    public string renderAs {get;Set;}
    public Boolean ran {get;Set;}
    public string listString {get; set;}
    
    //Multipicklists
    public List<SelectOption> selectedRegional {get; Set;}
    public List<SelectOption> selectedBrand {get; Set;}
    public List<SelectOption> selectedPOP {get; Set;}
    public List<SelectOption> allRegional {get; Set;}
    public List<SelectOption> allBrand {get; Set;}
    public List<SelectOption> allPOP {get; Set;}
    
    //Estructura que se utiliza para la tabla del reporte
    global class wrapReportRow{
        public string indicater {get;Set;}
        public List<Decimal> wvalues {get;set;}
        public List<string> wdates {get;set;}
        public Boolean firstReg {get;Set;}
        public Boolean isPercent {get;Set;}


         wrapReportRow(String tindicater, Boolean percent){
            this.indicater = tindicater;
            this.wdates = new List<String>();
            this.wvalues = new List<Decimal>();
            this.firstReg = false;
            this.isPercent = percent;
        }

    }

  
    
    //Estructura que se utiliza para la tabla de los filtros en caso de renderizar como PDF o Excel
    public class wrapFilter{
        public string regional {get;Set;}
        public string brands {get;Set;}
        public string pops {get;Set;}
        wrapFilter(){}
    }
    
    //VARIABLES PRIVADAS
    private static Map <string, integer> monthsByNames = new Map <string, integer>{'Janeiro' => 1, 'Fevereiro' => 2, 'Março' => 3, 'Abril' => 4, 'Maio' => 5, 'Junho' => 6, 'Julho' => 7, 'Agosto' => 8, 'Setembro' => 9, 'Outubro' => 10, 'Novembro' => 11, 'Dezembro' => 12};
    private static Map <integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
    private Map<string, Set<string>> mapCategoryBrands;

    
    //Constructor
    public LAT_AtivadoxNaoAtivadoCtrl() {
        
        ran = false;
        listString = '';
        listWrapersNew = new List<wrapReportRow>();

        hasAccess = true;
        
        
        //Inicializacion de variables
        selectedRegional = new List<SelectOption>();
        selectedBrand = new List<SelectOption>();
        selectedPOP = new List<SelectOption>();
        allRegional = new List<SelectOption>();
        allBrand = new List<SelectOption>();
        allPOP = new List<SelectOption>();
        planDesde = new Planejamento__c();
        planHasta = new Planejamento__c();
        
        planDesde.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().addMonths(-6).month()); 
        planDesde.Ano_de_Referencia__c = string.ValueOf(date.today().addMonths(-6).year()); 
        planHasta.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().month());
        planHasta.Ano_de_Referencia__c = string.ValueOf(date.today().year());
        
        //Carga de regiones
        for(UDC__c region: [SELECT id,name FROM UDC__c WHERE Internal_Id__c LIKE '1-%-01-01']){
            allRegional.add(new SelectOption(region.name,region.name));
        }

      
        
        //Carga de Categorias y Marcas
        mapCategoryBrands = new Map<string, Set<string>>();
        
        List<AggregateResult> resultProds = [SELECT Key_Brand__r.name brand, name FROM LAT_Produto_POP__c WHERE Key_Brand__c != null GROUP BY Key_Brand__r.name, name];
        for(AggregateResult result: resultProds){
            String brand = String.ValueOf(result.get('brand'));
            String materialPOP = String.ValueOf(result.get('name'));
            if(mapCategoryBrands.containsKey(brand)){
                mapCategoryBrands.get(brand).add(materialPOP);
            }else{
                mapCategoryBrands.put(brand, new Set<string>{materialPOP});
            }
        }
        for(string br: mapCategoryBrands.keySet()){
            allBrand.add(new SelectOption(br, br));
        }

    }

    public static boolean tieneEntrega(Account acc, Date dt){
        Date fromDate = dt.addMonths(-3);

        
        for(LAT_ClientPOP__c cl : acc.Cliente_POP__r){
            system.debug(cl.Delivered_Date__c + '   '+ fromDate +'  ' +dt);
            if(cl.Delivered_Date__c >= fromDate && cl.Delivered_Date__c < dt){
                return true;
            }
        }
        return false;
    }

    @RemoteAction
    global static List<wrapReportRow> doExecuteReport(List<String> Regions, List<String> Brands, List<String> pops,
                                                String startMonth, String startYear, String finishMonth, String finishYear){
      if(!Utils.wasMigrationDone('1')) {  

            List<wrapReportRow> listWrapersNew = new List<wrapReportRow>();

             //Generacion de filtros fecha
            integer fromMonth = monthsByNames.get(startMonth);
            integer toMonth = monthsByNames.get(finishMonth);
            integer fromYear = integer.valueOf(startYear);
            integer toYear = integer.valueOf(finishYear);
            Date fromDate = date.newinstance(fromYear, fromMonth, 1);
            Date toDate = date.newinstance(toYear, toMonth, 1);


            List<Date> listYearMonth = new List<date>();
            List<String> groupingList = new List<String>();
            Map<String, double> accVolumen = new Map<String, Double>();


            //Armo la lista de meses para el query
            date countDate = fromDate.addMonths(-1);
            toDate = toDate.addMonths(1).addDays(-1);
            while(countDate <= toDate){
                listYearMonth.add(countDate);
                countDate = countDate.addMonths(1);
            }

            for(LAT_ReferenceProduct__c rpro : [Select id,ReferenceGrouping__c from LAT_ReferenceProduct__c where SKURef__r.LAT_ScheduleC__r.KeyBrand__r.name in:Brands]){
                groupingList.add(rpro.ReferenceGrouping__c);
            }

            for(LAT_SellOutCollectLine__c sellOutLine : [Select id,SellOutCollect__r.ReferencedMonth__c,SellOutCollect__r.AccountID__c,SellOut__c from LAT_SellOutCollectLine__c where ReferenceProductGrouping__c in:groupingList AND SellOutCollect__r.recordtype.developerName = 'LAT_Volumen' AND SellOutCollect__r.ReferencedMonth__c >=: fromDate.addMonths(-1) AND SellOutCollect__r.ReferencedMonth__c <=: toDate AND SellOutCollect__r.AccountID__r.Status__c != 'Cliente inativo' AND SellOutCollect__r.AccountID__r.Status__c != 'Novo Cadastro' AND SellOutCollect__r.AccountID__r.recordtype.developerName = 'On_Trade' AND SellOutCollect__r.AccountID__r.Regional__r.name in: Regions]){
                Integer month = sellOutLine.SellOutCollect__r.ReferencedMonth__c.month();
                Integer year = sellOutLine.SellOutCollect__r.ReferencedMonth__c.year();
                String key =  sellOutLine.SellOutCollect__r.AccountID__c + '' + month + '/'+ year;
                system.debug('66666 ' + key);
                if(accVolumen.get(key) == null){
                    accVolumen.put(key,sellOutLine.SellOut__c);
                }else{ 
                    accVolumen.put(key, accVolumen.get(key)+sellOutLine.SellOut__c);
                }
            }

            
            List<Account> accs;
            if(pops.size()>0){
                accs  = [Select id,(Select id,Delivered_Date__c from Cliente_POP__r where Delivered_Date__c != null and Material_POP__r.name in: pops order by Delivered_Date__c) from account where Status__c != 'Cliente inativo' AND Status__c != 'Novo Cadastro' AND recordtype.developerName = 'On_Trade' AND Regional__r.name in: Regions];
            }else{
                accs  = [Select id,(Select id,Delivered_Date__c from Cliente_POP__r where Delivered_Date__c != null order by Delivered_Date__c) from account where Status__c != 'Cliente inativo' AND Status__c != 'Novo Cadastro' AND recordtype.developerName = 'On_Trade' AND Regional__r.name in: Regions];
            } 


            wrapReportRow wrAtivado = new wrapReportRow('PDD ATIVADO', False);
            wrapReportRow wrVolAtivado = new wrapReportRow('Volume PDD ATIVADO', False);
            wrapReportRow wrPerVolAtivado = new wrapReportRow('% PDD ATIVADO', True);
            wrapReportRow wrNAtivado = new wrapReportRow('PDD Ñ ATIVADO',False);
            wrapReportRow wrVolNAtivado = new wrapReportRow('Volume PDD Ñ ATIVADO',False);
            wrapReportRow wrPerVolNAtivado = new wrapReportRow('% PDD Ñ ATIVADO',True);
            wrapReportRow wrDif = new wrapReportRow('ATIVADO x NÃO ATIVADO',True);
            
            List<Decimal> wrVolNAtivadoValues = new List<Decimal>();
            List<Decimal> wrVolAtivadoValues = new List<Decimal>();
            
            system.debug('aaaa ' + accVolumen); 

            for(integer i = 0; i<listYearMonth.size();i++){
                wrAtivado.wdates.add(listYearMonth[i].month() + '/' + listYearMonth[i].year());
                wrAtivado.wvalues.add(0);

                wrVolAtivado.wdates.add(listYearMonth[i].month() + '/' + listYearMonth[i].year());
                wrVolAtivado.wvalues.add(0);

                wrNAtivado.wdates.add(listYearMonth[i].month() + '/' + listYearMonth[i].year());
                wrNAtivado.wvalues.add(0);

                wrVolNAtivado.wdates.add(listYearMonth[i].month() + '/' + listYearMonth[i].year());
                wrVolNAtivado.wvalues.add(0);

                Decimal nVol = 0;
                Decimal Vol = 0;


                for(Account acc : accs){
                    String key =  acc.id + '' + listYearMonth[i].month() + '/' + listYearMonth[i].year();

                    if(i < listYearMonth.size() -1){
                        if(tieneEntrega(acc, listYearMonth[i + 1])){
                            vol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        }else{
                            nVol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        }
                    }
                    if(i > 0){
                        String lastMonthkey =  acc.id + '' + listYearMonth[i-1].month() + '/' + listYearMonth[i-1].year();
                        if(tieneEntrega(acc, listYearMonth[i])){
                            wrVolAtivado.wvalues[i] += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                            wrAtivado.wvalues[i]++;
                            if(i == listYearMonth.size() -1){
                                vol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                            }
                        }else{
                            wrVolNAtivado.wvalues[i] += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                            if(accVolumen.get(key) != null && accVolumen.get(lastMonthkey) != null){
                                wrNAtivado.wvalues[i]++;
                            }
                            if(i == listYearMonth.size() -1){
                                nVol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                            }
                        }
                    }
                }

                system.debug('hhhhh ' + nVol);
                wrVolAtivadoValues.add(vol);
                wrVolNAtivadoValues.add(nVol);
            }




            for(integer i = 1; i<wrVolAtivado.wvalues.size();i++){
                wrPerVolAtivado.wdates.add(wrVolAtivado.wdates[i]);
                if(wrVolAtivadoValues[i-1] == 0){
                    wrPerVolAtivado.wvalues.add(100);
                }else{
                    wrPerVolAtivado.wvalues.add(Math.ROUND((( wrVolAtivadoValues[i]/ wrVolAtivadoValues[i-1])-1)*100));
                }


                wrPerVolNAtivado.wdates.add(wrVolNAtivado.wdates[i]);
                if(wrVolNAtivadoValues[i-1] == 0 || wrVolNAtivadoValues[i] == 0){
                    wrPerVolNAtivado.wvalues.add(0);
                }else{
                    wrPerVolNAtivado.wvalues.add(Math.ROUND((( wrVolNAtivadoValues[i] / wrVolNAtivadoValues[i-1])-1)*100));
                }


                wrDif.wdates.add(wrVolAtivado.wdates[i-1]);
                if(wrVolNAtivadoValues[i-1] == 0 || wrVolNAtivadoValues[i] == 0){
                    wrDif.wvalues.add(-10001);
                    wrVolNAtivado.wvalues[i] = 0;
                    wrNAtivado.wvalues[i] = 0;
                }else{
                    wrDif.wvalues.add(wrPerVolAtivado.wvalues[i-1] - wrPerVolNAtivado.wvalues[i-1]);
                }

            }

            wrAtivado.wvalues.remove(0);
            wrAtivado.wdates.remove(0);
            wrVolAtivado.wvalues.remove(0);
            wrVolAtivado.wdates.remove(0);
            wrNAtivado.wvalues.remove(0);
            wrNAtivado.wdates.remove(0);
            wrVolNAtivado.wvalues.remove(0);
            wrVolNAtivado.wdates.remove(0);

            

            listWrapersNew.add(wrAtivado);
            listWrapersNew.add(wrVolAtivado);
            listWrapersNew.add(wrPerVolAtivado);
            listWrapersNew.add(wrNAtivado);
            listWrapersNew.add(wrVolNAtivado);
            listWrapersNew.add(wrPerVolNAtivado);
            listWrapersNew.add(wrDif);
            

            return listWrapersNew;
        } 
        //MIGRATED 18/11/2016
        else {

            List<wrapReportRow> listWrapersNew = new List<wrapReportRow>();

             //Generacion de filtros fecha
            integer fromMonth = monthsByNames.get(startMonth);
            integer toMonth = monthsByNames.get(finishMonth);
            integer fromYear = integer.valueOf(startYear);
            integer toYear = integer.valueOf(finishYear);
            Date fromDate = date.newinstance(fromYear, fromMonth, 1);
            Date toDate = date.newinstance(toYear, toMonth, 1);


            List<Date> listYearMonth = new List<date>();
            List<String> groupingList = new List<String>();
            Map<String, double> accVolumen = new Map<String, Double>();


            //Armo la lista de meses para el query
            date countDate = fromDate.addMonths(-1);
            toDate = toDate.addMonths(1).addDays(-1);
            while(countDate <= toDate){
                listYearMonth.add(countDate);
                countDate = countDate.addMonths(1);
            }

            for(LAT_ReferenceProduct__c rpro : [Select id,ReferenceGrouping__c from LAT_ReferenceProduct__c where LAT_Product__r.LAT_ScheduleC__r.KeyBrand__r.name in:Brands]){
                groupingList.add(rpro.ReferenceGrouping__c);
            }

            for(LAT_SellOutCollectLine__c sellOutLine : [Select id,SellOutCollect__r.ReferencedMonth__c,SellOutCollect__r.AccountID__c,SellOut__c from LAT_SellOutCollectLine__c where ReferenceProductGrouping__c in:groupingList AND SellOutCollect__r.recordtype.developerName = 'LAT_Volumen' AND SellOutCollect__r.ReferencedMonth__c >=: fromDate.addMonths(-1) AND SellOutCollect__r.ReferencedMonth__c <=: toDate AND SellOutCollect__r.AccountID__r.Status__c != 'Cliente inativo' AND SellOutCollect__r.AccountID__r.Status__c != 'Novo Cadastro' AND SellOutCollect__r.AccountID__r.recordtype.developerName = 'On_Trade' AND SellOutCollect__r.AccountID__r.Regional__r.name in: Regions]){
                Integer month = sellOutLine.SellOutCollect__r.ReferencedMonth__c.month();
                Integer year = sellOutLine.SellOutCollect__r.ReferencedMonth__c.year();
                String key =  sellOutLine.SellOutCollect__r.AccountID__c + '' + month + '/'+ year;
                system.debug('66666 ' + key);
                if(accVolumen.get(key) == null){
                    accVolumen.put(key,sellOutLine.SellOut__c);
                }else{ 
                    accVolumen.put(key, accVolumen.get(key)+sellOutLine.SellOut__c);
                }
            }

            
            List<Account> accs;
            if(pops.size()>0){
                accs  = [Select id,(Select id,Delivered_Date__c from Cliente_POP__r where Delivered_Date__c != null and Material_POP__r.name in: pops order by Delivered_Date__c) from account where Status__c != 'Cliente inativo' AND Status__c != 'Novo Cadastro' AND recordtype.developerName = 'On_Trade' AND Regional__r.name in: Regions];
            }else{
                accs  = [Select id,(Select id,Delivered_Date__c from Cliente_POP__r where Delivered_Date__c != null order by Delivered_Date__c) from account where Status__c != 'Cliente inativo' AND Status__c != 'Novo Cadastro' AND recordtype.developerName = 'On_Trade' AND Regional__r.name in: Regions];
            } 


            wrapReportRow wrAtivado = new wrapReportRow('PDD ATIVADO', False);
            wrapReportRow wrVolAtivado = new wrapReportRow('Volume PDD ATIVADO', False);
            wrapReportRow wrPerVolAtivado = new wrapReportRow('% PDD ATIVADO', True);
            wrapReportRow wrNAtivado = new wrapReportRow('PDD Ñ ATIVADO',False);
            wrapReportRow wrVolNAtivado = new wrapReportRow('Volume PDD Ñ ATIVADO',False);
            wrapReportRow wrPerVolNAtivado = new wrapReportRow('% PDD Ñ ATIVADO',True);
            wrapReportRow wrDif = new wrapReportRow('ATIVADO x NÃO ATIVADO',True);
            
            List<Decimal> wrVolNAtivadoValues = new List<Decimal>();
            List<Decimal> wrVolAtivadoValues = new List<Decimal>();
            
            system.debug('aaaa ' + accVolumen); 

            for(integer i = 0; i<listYearMonth.size();i++){
                wrAtivado.wdates.add(listYearMonth[i].month() + '/' + listYearMonth[i].year());
                wrAtivado.wvalues.add(0);

                wrVolAtivado.wdates.add(listYearMonth[i].month() + '/' + listYearMonth[i].year());
                wrVolAtivado.wvalues.add(0);

                wrNAtivado.wdates.add(listYearMonth[i].month() + '/' + listYearMonth[i].year());
                wrNAtivado.wvalues.add(0);

                wrVolNAtivado.wdates.add(listYearMonth[i].month() + '/' + listYearMonth[i].year());
                wrVolNAtivado.wvalues.add(0);

                Decimal nVol = 0;
                Decimal Vol = 0;


                for(Account acc : accs){
                    String key =  acc.id + '' + listYearMonth[i].month() + '/' + listYearMonth[i].year();

                    if(i < listYearMonth.size() -1){
                        if(tieneEntrega(acc, listYearMonth[i + 1])){
                            vol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        }else{
                            nVol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        }
                    }
                    if(i > 0){
                        String lastMonthkey =  acc.id + '' + listYearMonth[i-1].month() + '/' + listYearMonth[i-1].year();
                        if(tieneEntrega(acc, listYearMonth[i])){
                            wrVolAtivado.wvalues[i] += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                            wrAtivado.wvalues[i]++;
                            if(i == listYearMonth.size() -1){
                                vol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                            }
                        }else{
                            wrVolNAtivado.wvalues[i] += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                            if(accVolumen.get(key) != null && accVolumen.get(lastMonthkey) != null){
                                wrNAtivado.wvalues[i]++;
                            }
                            if(i == listYearMonth.size() -1){
                                nVol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                            }
                        }
                    }
                }

                system.debug('hhhhh ' + nVol);
                wrVolAtivadoValues.add(vol);
                wrVolNAtivadoValues.add(nVol);
            }




            for(integer i = 1; i<wrVolAtivado.wvalues.size();i++){
                wrPerVolAtivado.wdates.add(wrVolAtivado.wdates[i]);
                if(wrVolAtivadoValues[i-1] == 0){
                    wrPerVolAtivado.wvalues.add(100);
                }else{
                    wrPerVolAtivado.wvalues.add(Math.ROUND((( wrVolAtivadoValues[i]/ wrVolAtivadoValues[i-1])-1)*100));
                }


                wrPerVolNAtivado.wdates.add(wrVolNAtivado.wdates[i]);
                if(wrVolNAtivadoValues[i-1] == 0 || wrVolNAtivadoValues[i] == 0){
                    wrPerVolNAtivado.wvalues.add(0);
                }else{
                    wrPerVolNAtivado.wvalues.add(Math.ROUND((( wrVolNAtivadoValues[i] / wrVolNAtivadoValues[i-1])-1)*100));
                }


                wrDif.wdates.add(wrVolAtivado.wdates[i-1]);
                if(wrVolNAtivadoValues[i-1] == 0 || wrVolNAtivadoValues[i] == 0){
                    wrDif.wvalues.add(-10001);
                    wrVolNAtivado.wvalues[i] = 0;
                    wrNAtivado.wvalues[i] = 0;
                }else{
                    wrDif.wvalues.add(wrPerVolAtivado.wvalues[i-1] - wrPerVolNAtivado.wvalues[i-1]);
                }

            }

            wrAtivado.wvalues.remove(0);
            wrAtivado.wdates.remove(0);
            wrVolAtivado.wvalues.remove(0);
            wrVolAtivado.wdates.remove(0);
            wrNAtivado.wvalues.remove(0);
            wrNAtivado.wdates.remove(0);
            wrVolNAtivado.wvalues.remove(0);
            wrVolNAtivado.wdates.remove(0);

            

            listWrapersNew.add(wrAtivado);
            listWrapersNew.add(wrVolAtivado);
            listWrapersNew.add(wrPerVolAtivado);
            listWrapersNew.add(wrNAtivado);
            listWrapersNew.add(wrVolNAtivado);
            listWrapersNew.add(wrPerVolNAtivado);
            listWrapersNew.add(wrDif);
            

            return listWrapersNew;            
        }

    }
        
    //Metodo para agregar una categoria a los filtros
    public PageReference doAddCategory(){
        Set<string> seleccionadas = new Set<string>();
        seleccionadas.addAll(leftOptionsHidden.split(',,,'));
        
        for(string str: seleccionadas){
            if(str!=null && str!=''){
                selectedBrand.add(new selectoption(str,str));
            }
        }
        for(integer i=0; i<allBrand.size(); i++){
            if(seleccionadas.contains(allBrand[i].getValue())){
                allBrand.remove(i); i--;
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
                allBrand.add(new selectoption(str,str));
            }
        }
        for(integer i=0;i<selectedBrand.size();i++){
            if(seleccionadas.contains(selectedBrand[i].getValue())){
                selectedBrand.remove(i); i--;
            }
        }
        reloadBrands();
        return null;
    }
    
    //Metodo que recalcula las Marcas segun las Categorias
    private void reloadBrands(){
        //Armo el Set de marcas habilitadas para todas las categorias seleccionadas
        Set<string> setAvailableBrands = new Set<string>();
        for(selectoption sel: selectedBrand){
            if(mapCategoryBrands.containskey(sel.getvalue())){
                for(string val: mapCategoryBrands.get(sel.getvalue())){
                    setAvailableBrands.add(val);
                }
            }
        }
        
        //Quito de la lista de marcas seleccionadas las que estén afuera de las habilitadas
        for(integer i=0; i< selectedPOP.size(); i++){
            if(!setAvailableBrands.contains(selectedPOP[i].getvalue())){
                selectedPOP.remove(i); i--;
            }
        }
        
        //Armo un Set de las marcas seleccionadas
        Set<string> setSelectedPOP = new Set<string>();
        for(selectoption sel: selectedPOP){
            setSelectedPOP.add(sel.getValue());
        }
        
        //Borro la lista de marcas disponibles y agrego todas las que no estén en seleccionadas
        allPOP = new List<SelectOption>();
        for(string val: setAvailableBrands){
            if((!setSelectedPOP.contains(val))){
                allPOP.add(new selectoption(val, val));
            }
        }
    }
    
    //Metodo para renderizar el reporte como PDF
    public pageReference doExportPDF(){
        system.debug('&&&& ' + listString);
        loadFilters();
        renderAs = 'pdf';

        JSONParser parser = JSON.createParser(listString);
        while (parser.nextToken() != null) {
            // Start at the array of invoices.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next invoice statement object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire invoice object, including its array of line items.
                        wrapReportRow wra = (wrapReportRow)parser.readValueAs(wrapReportRow.class);
                        listWrapersNew.add(wra);
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                    }
                }
            }
        }
        
        pageReference pr = system.currentPageReference();
        return pr;
    }
    
    //Metodo para renderizar el reporte como Excel
    public pageReference doExportExcel(){
        system.debug('&&&& ' + listString);
        loadFilters();
        renderAs = 'excel';

        JSONParser parser = JSON.createParser(listString);
        while (parser.nextToken() != null) {
            // Start at the array of invoices.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next invoice statement object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire invoice object, including its array of line items.
                        wrapReportRow wra = (wrapReportRow)parser.readValueAs(wrapReportRow.class);
                        listWrapersNew.add(wra);
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                    }
                }
            }
        }

        pageReference pr = system.currentPageReference();
        return pr;
    }
    
    //Metodo para mostrar los filtros seleccionados cuando se hace el renderizado a PDF o Excel
    private void loadFilters(){
        pdfFilters = new List<wrapFilter>();
        List<Integer> listSizes = new List<Integer>{selectedBrand.size(), selectedPOP.size(), selectedRegional.size()};
        listSizes.sort();
        for(Integer i=0; i<listSizes[2]; i++){
            wrapFilter wf = new wrapFilter();
            try{wf.regional = selectedRegional[i].getValue();}catch(Exception e){}
            try{wf.brands = selectedBrand[i].getValue();}catch(Exception e){}
            try{wf.pops = selectedPOP[i].getValue();}catch(Exception e){}
            pdfFilters.add(wf);
        }
    }
    
    //Metodo para tomar el color del Tab "Custom Reports" y utilizarlo en la tabla del reporte
    public string getColorTab(){
        return '#b4c374';
    }
}