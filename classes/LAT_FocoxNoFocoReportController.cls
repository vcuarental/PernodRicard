/*************************************************************************************************
*                                    Company: Zimmic                                             * 
*------------------------------------------------------------------------------------------------*
*              Controlador del la Visualforce page LAT_FocoxNoFocoReportController            *
**************************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/
global without sharing class LAT_FocoxNoFocoReportController {
    
    //VARIABLES PUBLICAS
    public List<wrapReportRow> listWrapersNew {get;Set;}
    public List<wrapAnaliticReportRow> listWrapersAnaliticNew {get;Set;}
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
    public Boolean showHeader {get;Set;}
    public Boolean isAnalitic {get;Set;}
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


        global wrapReportRow(String tindicater, Boolean percent){
            this.indicater = tindicater;
            this.wdates = new List<String>();
            this.wvalues = new List<Decimal>();
            this.firstReg = false;
            this.isPercent = percent;
        }

    }

    //Estructura que se utiliza para la tabla del reporte
    global class wrapAnaliticReportRow{
        //Client Information
        public String clientId {get;set;}
        public String clientName {get;set;}
        
        // Values
        public Decimal volumen {get;set;}
        public Decimal percent {get;set;}

        // Month/Year
        public String monthPeriod {get; set;}

        //indicates if this is ativado or not
        public string type {get; set;}

        global wrapAnaliticReportRow(String clientId, String clientName, Decimal volume, Decimal per, String type,
                                        String monthPeriod){
            this.clientId = clientId;
            this.clientName = clientName;
            this.volumen = volume;
            this.percent = per;
            this.monthPeriod = monthPeriod;
            this.type = type;
        }

    }

    //Estructura que se utiliza para la tabla de los filtros en caso de renderizar como PDF o Excel
    public class wrapFilter{
        public string regional {get;Set;}
        public string brands {get;Set;}
        public string pops {get;Set;}
        public wrapFilter(){}
    }
    
    //VARIABLES PRIVADAS
    private static Map <string, integer> monthsByNames = new Map <string, integer>{'Janeiro' => 1, 'Fevereiro' => 2, 'Março' => 3, 'Abril' => 4, 'Maio' => 5, 'Junho' => 6, 'Julho' => 7, 'Agosto' => 8, 'Setembro' => 9, 'Outubro' => 10, 'Novembro' => 11, 'Dezembro' => 12};
    private static Map <integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
    private Map<string, Set<string>> mapCategoryBrands;
    public List<String> excludeClientStatus = new List<String>{'Ação cancelada pela PRB', 'Cliente Selecionado', 'Cliente Validado', 'Cliente Substituto', 'Cliente não aprovado', 'Ação não aprovada pelo cliente'};
    public List<String> apStatus = new List<String>{'Ação iniciada', 'Ação Finalizada'};


    //Constructor
    public LAT_FocoxNoFocoReportController() {
        Map<String,String> params = ApexPages.currentPage().getParameters();

        ran = false;
        isAnalitic = false;
        showHeader = true;
        listString = '';
        listWrapersNew = new List<wrapReportRow>();
        listWrapersAnaliticNew = new List<wrapAnaliticReportRow>();
        hasAccess = true;
        
        if (params.get('hideHeader') != null) {
            showHeader = false;
        }
        if (params.get('isAnalitic') != null) {
            isAnalitic = true;
        }

        //Inicializacion de variables
        selectedRegional = new List<SelectOption>();
        selectedBrand = new List<SelectOption>();
        selectedPOP = new List<SelectOption>();
        allRegional = new List<SelectOption>();
        allBrand = new List<SelectOption>();
        allPOP = new List<SelectOption>();
        planDesde = new Planejamento__c();
        planHasta = new Planejamento__c();
        
        if (isAnalitic) {
            planDesde.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().addMonths(-1).month()); 
            planDesde.Ano_de_Referencia__c = string.ValueOf(date.today().addMonths(-1).year()); 
            planHasta.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().month());
            planHasta.Ano_de_Referencia__c = string.ValueOf(date.today().year());
        } else {
            planDesde.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().addMonths(-6).month()); 
            planDesde.Ano_de_Referencia__c = string.ValueOf(date.today().addMonths(-6).year()); 
            planHasta.M_s_de_Ref_rencia__c = monthsByNum.get(date.today().month());
            planHasta.Ano_de_Referencia__c = string.ValueOf(date.today().year());
        }
        
        //Carga de regiones
        for(UDC__c region: [SELECT id,name FROM UDC__c WHERE Internal_Id__c LIKE '1-%-01-01']){
            allRegional.add(new SelectOption(region.name,region.name));
        }
        
        //Carga de Categorias y Marcas
        mapCategoryBrands = getCategoryBrands(planDesde, planHasta, isAnalitic);
        
        for(string br: mapCategoryBrands.keySet()){
            allBrand.add(new SelectOption(br, br));
        }

    }

    public static void initialAction(string Origin) {
        try {
            LAT_Log__c log = new LAT_Log__c();
            log.LAT_Date__c = Date.Today();
            log.LAT_Origin__c = 'FocoxNoFoco';
            log.LAT_StartTime__c = DateTime.now();
            insert log;
        } catch (exception e) {}
    }

    public static Map<string, Set<string>> getCategoryBrands(Planejamento__c planDesde, Planejamento__c planHasta, Boolean isAnalitic) {
        Map<string, Set<string>> returnMapCategoryBrands = new Map<string, Set<string>>();
        List<String> apStatus = new List<String>{'Ação iniciada', 'Ação Finalizada'};

        Date startFilterDate = Date.newInstance(Integer.valueOf(planDesde.Ano_de_Referencia__c), Integer.valueOf(monthsByNames.get(planDesde.M_s_de_Ref_rencia__c)), 1);
        Integer numberOfDays = Date.daysInMonth(Integer.valueOf(planHasta.Ano_de_Referencia__c), Integer.valueOf(monthsByNames.get(planHasta.M_s_de_Ref_rencia__c)));
        Date finishFilterDate = Date.newInstance(Integer.valueOf(planHasta.Ano_de_Referencia__c), Integer.valueOf(monthsByNames.get(planHasta.M_s_de_Ref_rencia__c)), numberOfDays);

        List<AggregateResult> resultProds = [SELECT LAT_KeyBrand__r.name brand, Promotional_Action__r.Name prom FROM LAT_PromotionalActionKeyBrands__c 
                                                WHERE LAT_KeyBrand__c != null 
                                                    AND Promotional_Action__r.LAT_StartDate__c <: finishFilterDate  
                                                    AND  Promotional_Action__r.LAT_EndDate__c >: startFilterDate
                                                    AND Promotional_Action__r.LAT_Status__c IN: apStatus
                                                GROUP BY LAT_KeyBrand__r.name, Promotional_Action__r.Name];
        if (isAnalitic) {
            Date currentDate = Date.today();
            resultProds = [SELECT LAT_KeyBrand__r.name brand, Promotional_Action__r.Name prom FROM LAT_PromotionalActionKeyBrands__c 
                                    WHERE LAT_KeyBrand__c != null 
                                        AND (Promotional_Action__r.LAT_StartDate__c <=: currentDate
                                            AND  Promotional_Action__r.LAT_EndDate__c >=: currentDate
                                            AND Promotional_Action__r.LAT_Status__c IN: apStatus)
                                    GROUP BY LAT_KeyBrand__r.name, Promotional_Action__r.Name];
        } 
        for(AggregateResult result: resultProds){
            String brand = String.ValueOf(result.get('brand'));
            String actionBrand = String.ValueOf(result.get('prom'));
            if(returnMapCategoryBrands.containsKey(brand)){
                returnMapCategoryBrands.get(brand).add(actionBrand);
            }else{
                returnMapCategoryBrands.put(brand, new Set<string>{actionBrand});
            }
        }

        return returnMapCategoryBrands;

    }

    public static boolean tieneFoco(Account acc, Date startDt){
        //Date fromDate = dt.addMonths(-3);
        Integer numberOfDays = Date.daysInMonth(startDt.year(), startDt.month());
        Date endDt = Date.newInstance(startDt.year(), startDt.month(), numberOfDays);

        for(LAT_AccountInAction__c cl : acc.LAT_AccountInAction__r){
            system.debug(cl.LAT_PromotionalAction__r.LAT_StartDate__c + '   '+ endDt +'  ' +startDt);
            /*if ((startDt > cl.LAT_PromotionalAction__r.LAT_StartDate__c  && startDt < cl.LAT_PromotionalAction__r.LAT_EndDate__c)
                || (cl.LAT_PromotionalAction__r.LAT_StartDate__c > startDt && cl.LAT_PromotionalAction__r.LAT_StartDate__c < endDt)
                || (cl.LAT_PromotionalAction__r.LAT_EndDate__c > startDt && cl.LAT_PromotionalAction__r.LAT_EndDate__c < endDt)) {*/
            if (startDt < cl.LAT_PromotionalAction__r.LAT_EndDate__c && cl.LAT_PromotionalAction__r.LAT_StartDate__c < endDt) {
                return true;
            }
        }
        return false;
    }

    @RemoteAction
    global static List<Account> getAccountsForAnalitic(List<String> Regions, List<String> aps){
        initialAction('FocoxNoFoco Analitic Executed');
        List<String> excludeClientStatus = new List<String>{'Ação cancelada pela PRB', 'Cliente Selecionado', 'Cliente Validado', 'Cliente Substituto', 'Cliente não aprovado', 'Ação não aprovada pelo cliente'};
        return [SELECT id, Name, (Select id, LAT_PromotionalAction__r.LAT_StartDate__c, LAT_PromotionalAction__r.LAT_EndDate__c 
                                    from LAT_AccountInAction__r 
                                    where LAT_PromotionalAction__r.name in: aps AND LAT_Status__c !=: excludeClientStatus order by LAT_PromotionalAction__r.LAT_StartDate__c) 
                        FROM account WHERE Status__c != 'Cliente inativo' AND Status__c != 'Novo Cadastro' 
                            AND recordtype.developerName = 'On_Trade' AND Regional__r.name in: Regions];
    }

    @RemoteAction
    global static List<wrapAnaliticReportRow> doExecuteAnaliticReport(List<String> Regions, List<String> Brands, List<String> aps, 
                                                                    string accountId, string accountName, List<String> datesStrings){
        if(!Utils.wasMigrationDone('1')) { 
            List<String> excludeClientStatus = new List<String>{'Ação cancelada pela PRB', 'Cliente Selecionado', 'Cliente Validado', 'Cliente Substituto', 'Cliente não aprovado', 'Ação não aprovada pelo cliente'};
            List<wrapAnaliticReportRow> listWrapersNew = new List<wrapAnaliticReportRow>();

            //Generacion de filtros fecha
            //Date fromDate = Date.today().addMonths(-1);
            //Date toDate = Date.today();

            if (!datesStrings.isEmpty()) {
                String[] fromD = datesStrings.get(0).split('/');
                String[] toD = datesStrings.get(datesStrings.size()-1).split('/');
                integer toMonth = monthsByNames.get(toD[0]);
                integer toYear = integer.valueOf(toD[1]);
                integer fromMonth = monthsByNames.get(fromD[0]);
                integer fromYear = integer.valueOf(fromD[1]);
                Date toDate = date.newinstance(toYear, toMonth, 1);
                Date fromDate = date.newinstance(fromYear, fromMonth, 1);

                List<Date> listYearMonth = new List<date>();
                List<String> groupingList = new List<String>();
                Map<String, double> accVolumen = new Map<String, Double>();

                for(LAT_ReferenceProduct__c rpro : [Select id,ReferenceGrouping__c from LAT_ReferenceProduct__c 
                                                        where SKURef__r.LAT_ScheduleC__r.KeyBrand__r.name in:Brands]){
                    groupingList.add(rpro.ReferenceGrouping__c);
                }

                for(LAT_SellOutCollectLine__c sellOutLine : [Select id,SellOutCollect__r.ReferencedMonth__c,SellOutCollect__r.AccountID__c,
                                                                    SellOut__c from LAT_SellOutCollectLine__c 
                                                                where ReferenceProductGrouping__c in:groupingList 
                                                                    AND SellOutCollect__r.recordtype.developerName = 'LAT_Volumen' 
                                                                    AND SellOutCollect__r.ReferencedMonth__c >=: fromDate.addMonths(-1) 
                                                                    AND SellOutCollect__r.ReferencedMonth__c <=: toDate 
                                                                    AND SellOutCollect__r.AccountID__r.Status__c != 'Cliente inativo' 
                                                                    AND SellOutCollect__r.AccountID__r.Status__c != 'Novo Cadastro' 
                                                                    AND SellOutCollect__r.AccountID__r.recordtype.developerName = 'On_Trade' 
                                                                    AND SellOutCollect__r.AccountID__c =: accountId]){
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

                List<Account> accs = [Select id, Name, (Select id, LAT_PromotionalAction__r.LAT_StartDate__c, LAT_PromotionalAction__r.LAT_EndDate__c 
                                                    from LAT_AccountInAction__r where LAT_PromotionalAction__r.name in: aps AND LAT_Status__c !=: excludeClientStatus
                                                    order by LAT_PromotionalAction__r.LAT_StartDate__c) 
                                    from account where id =: accountId];

                system.debug('accs------->' + accs);
                
                if (!accs.isEmpty()) {

                    Account acc = accs.get(0);
                    for (String ds: datesStrings) {
                        toD = ds.split('/');
                        toMonth = monthsByNames.get(toD[0]);
                        toYear = integer.valueOf(toD[1]);
                        
                        toDate = date.newinstance(toYear, toMonth, 1);
                        fromDate = toDate.addMonths(-1);
                        
                        system.debug('to------>' + toDate);
                        system.debug('from------>' + fromDate);

                        String key =  acc.id + '' + toDate.month() + '/' + toDate.year();
                        Decimal vol = accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        wrapAnaliticReportRow analiticRow = new wrapAnaliticReportRow(acc.Id, acc.Name, vol, 0, '', ds);

                        if (tieneFoco(acc, toDate)) {
                            analiticRow.type = 'Ativado';
                        } else {
                            analiticRow.type = 'NAtivado';
                        }

                        String fromKey = acc.id + '' + fromDate.month() + '/' + fromDate.year();
                        Decimal fromVol = accVolumen.get(fromKey) == null ? 0 : accVolumen.get(fromKey);

                        Decimal perVol = 100;
                        if (fromVol != 0) {
                            perVol = Math.ROUND(((vol/ fromVol)-1)*100);
                        }
                        analiticRow.percent = perVol;
                        listWrapersNew.add(analiticRow);
                    }

                }
            }
            
            return listWrapersNew;
        }
        //MIGRATED 18/11/2016
        else {
            List<String> excludeClientStatus = new List<String>{'Ação cancelada pela PRB', 'Cliente Selecionado', 'Cliente Validado', 'Cliente Substituto', 'Cliente não aprovado', 'Ação não aprovada pelo cliente'};
            List<wrapAnaliticReportRow> listWrapersNew = new List<wrapAnaliticReportRow>();

            //Generacion de filtros fecha
            //Date fromDate = Date.today().addMonths(-1);
            //Date toDate = Date.today();

            if (!datesStrings.isEmpty()) {
                String[] fromD = datesStrings.get(0).split('/');
                String[] toD = datesStrings.get(datesStrings.size()-1).split('/');
                integer toMonth = monthsByNames.get(toD[0]);
                integer toYear = integer.valueOf(toD[1]);
                integer fromMonth = monthsByNames.get(fromD[0]);
                integer fromYear = integer.valueOf(fromD[1]);
                Date toDate = date.newinstance(toYear, toMonth, 1);
                Date fromDate = date.newinstance(fromYear, fromMonth, 1);

                List<Date> listYearMonth = new List<date>();
                List<String> groupingList = new List<String>();
                Map<String, double> accVolumen = new Map<String, Double>();

                for(LAT_ReferenceProduct__c rpro : [Select id,ReferenceGrouping__c from LAT_ReferenceProduct__c 
                                                        where LAT_Product__r.LAT_ScheduleC__r.KeyBrand__r.name in:Brands]){
                    groupingList.add(rpro.ReferenceGrouping__c);
                }

                for(LAT_SellOutCollectLine__c sellOutLine : [Select id,SellOutCollect__r.ReferencedMonth__c,SellOutCollect__r.AccountID__c,
                                                                    SellOut__c from LAT_SellOutCollectLine__c 
                                                                where ReferenceProductGrouping__c in:groupingList 
                                                                    AND SellOutCollect__r.recordtype.developerName = 'LAT_Volumen' 
                                                                    AND SellOutCollect__r.ReferencedMonth__c >=: fromDate.addMonths(-1) 
                                                                    AND SellOutCollect__r.ReferencedMonth__c <=: toDate 
                                                                    AND SellOutCollect__r.AccountID__r.Status__c != 'Cliente inativo' 
                                                                    AND SellOutCollect__r.AccountID__r.Status__c != 'Novo Cadastro' 
                                                                    AND SellOutCollect__r.AccountID__r.recordtype.developerName = 'On_Trade' 
                                                                    AND SellOutCollect__r.AccountID__c =: accountId]){
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

                List<Account> accs = [Select id, Name, (Select id, LAT_PromotionalAction__r.LAT_StartDate__c, LAT_PromotionalAction__r.LAT_EndDate__c 
                                                    from LAT_AccountInAction__r where LAT_PromotionalAction__r.name in: aps AND LAT_Status__c !=: excludeClientStatus
                                                    order by LAT_PromotionalAction__r.LAT_StartDate__c) 
                                    from account where id =: accountId];

                system.debug('accs------->' + accs);
                
                if (!accs.isEmpty()) {

                    Account acc = accs.get(0);
                    for (String ds: datesStrings) {
                        toD = ds.split('/');
                        toMonth = monthsByNames.get(toD[0]);
                        toYear = integer.valueOf(toD[1]);
                        
                        toDate = date.newinstance(toYear, toMonth, 1);
                        fromDate = toDate.addMonths(-1);
                        
                        system.debug('to------>' + toDate);
                        system.debug('from------>' + fromDate);

                        String key =  acc.id + '' + toDate.month() + '/' + toDate.year();
                        Decimal vol = accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        wrapAnaliticReportRow analiticRow = new wrapAnaliticReportRow(acc.Id, acc.Name, vol, 0, '', ds);

                        if (tieneFoco(acc, toDate)) {
                            analiticRow.type = 'Ativado';
                        } else {
                            analiticRow.type = 'NAtivado';
                        }

                        String fromKey = acc.id + '' + fromDate.month() + '/' + fromDate.year();
                        Decimal fromVol = accVolumen.get(fromKey) == null ? 0 : accVolumen.get(fromKey);

                        Decimal perVol = 100;
                        if (fromVol != 0) {
                            perVol = Math.ROUND(((vol/ fromVol)-1)*100);
                        }
                        analiticRow.percent = perVol;
                        listWrapersNew.add(analiticRow);
                    }

                }
            }
            
            return listWrapersNew;            
        }
    
    }

    @RemoteAction
    global static List<wrapReportRow> doExecuteReport(List<String> Regions, List<String> Brands, List<String> aps,
                                                String startMonth, String startYear, String finishMonth, String finishYear){
        if(!Utils.wasMigrationDone('1')) {            
            initialAction('FocoxNoFoco Sumary Executed');
            List<String> excludeClientStatus = new List<String>{'Ação cancelada pela PRB', 'Cliente Selecionado', 'Cliente Validado', 'Cliente Substituto', 'Cliente não aprovado', 'Ação não aprovada pelo cliente'};
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

            for(LAT_SellOutCollectLine__c sellOutLine : [Select id,SellOutCollect__r.ReferencedMonth__c,SellOutCollect__r.AccountID__c,SellOut__c 
                                                            from LAT_SellOutCollectLine__c 
                                                            where ReferenceProductGrouping__c in:groupingList 
                                                                AND SellOutCollect__r.recordtype.developerName = 'LAT_Volumen' 
                                                                AND SellOutCollect__r.ReferencedMonth__c >=: fromDate.addMonths(-1) 
                                                                AND SellOutCollect__r.ReferencedMonth__c <=: toDate 
                                                                AND SellOutCollect__r.AccountID__r.Status__c != 'Cliente inativo' 
                                                                AND SellOutCollect__r.AccountID__r.Status__c != 'Novo Cadastro' 
                                                                AND SellOutCollect__r.AccountID__r.recordtype.developerName = 'On_Trade' 
                                                                AND SellOutCollect__r.AccountID__r.Regional__r.name in: Regions]){
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
            if(aps.size()>0){
                accs  = [Select id,(Select id, LAT_PromotionalAction__r.LAT_StartDate__c, LAT_PromotionalAction__r.LAT_EndDate__c from LAT_AccountInAction__r where LAT_PromotionalAction__r.name in: aps AND LAT_Status__c !=: excludeClientStatus order by LAT_PromotionalAction__r.LAT_StartDate__c) from account where Status__c != 'Cliente inativo' AND Status__c != 'Novo Cadastro' AND recordtype.developerName = 'On_Trade' AND Regional__r.name in: Regions];
            }else{
                accs  = [Select id,(Select id, LAT_PromotionalAction__r.LAT_StartDate__c, LAT_PromotionalAction__r.LAT_EndDate__c from LAT_AccountInAction__r where LAT_Status__c !=: excludeClientStatus order by LAT_PromotionalAction__r.LAT_StartDate__c) from account where Status__c != 'Cliente inativo' AND Status__c != 'Novo Cadastro' AND recordtype.developerName = 'On_Trade' AND Regional__r.name in: Regions];
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
                        if(tieneFoco(acc, listYearMonth[i + 1])){
                            vol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        }else{
                            nVol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        }
                    }
                    if(i > 0){
                        String lastMonthkey =  acc.id + '' + listYearMonth[i-1].month() + '/' + listYearMonth[i-1].year();
                        if(tieneFoco(acc, listYearMonth[i])){
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
                system.debug('date------->' + wrVolAtivado.wdates[i]);
                system.debug('i------->' + wrVolAtivadoValues[i]);
                system.debug('i-1------->' + wrVolAtivadoValues[i-1]);
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
            initialAction('FocoxNoFoco Sumary Executed');
            List<String> excludeClientStatus = new List<String>{'Ação cancelada pela PRB', 'Cliente Selecionado', 'Cliente Validado', 'Cliente Substituto', 'Cliente não aprovado', 'Ação não aprovada pelo cliente'};
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

            for(LAT_SellOutCollectLine__c sellOutLine : [Select id,SellOutCollect__r.ReferencedMonth__c,SellOutCollect__r.AccountID__c,SellOut__c 
                                                            from LAT_SellOutCollectLine__c 
                                                            where ReferenceProductGrouping__c in:groupingList 
                                                                AND SellOutCollect__r.recordtype.developerName = 'LAT_Volumen' 
                                                                AND SellOutCollect__r.ReferencedMonth__c >=: fromDate.addMonths(-1) 
                                                                AND SellOutCollect__r.ReferencedMonth__c <=: toDate 
                                                                AND SellOutCollect__r.AccountID__r.Status__c != 'Cliente inativo' 
                                                                AND SellOutCollect__r.AccountID__r.Status__c != 'Novo Cadastro' 
                                                                AND SellOutCollect__r.AccountID__r.recordtype.developerName = 'On_Trade' 
                                                                AND SellOutCollect__r.AccountID__r.Regional__r.name in: Regions]){
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
            if(aps.size()>0){
                accs  = [Select id,(Select id, LAT_PromotionalAction__r.LAT_StartDate__c, LAT_PromotionalAction__r.LAT_EndDate__c from LAT_AccountInAction__r where LAT_PromotionalAction__r.name in: aps AND LAT_Status__c !=: excludeClientStatus order by LAT_PromotionalAction__r.LAT_StartDate__c) from account where Status__c != 'Cliente inativo' AND Status__c != 'Novo Cadastro' AND recordtype.developerName = 'On_Trade' AND Regional__r.name in: Regions];
            }else{
                accs  = [Select id,(Select id, LAT_PromotionalAction__r.LAT_StartDate__c, LAT_PromotionalAction__r.LAT_EndDate__c from LAT_AccountInAction__r where LAT_Status__c !=: excludeClientStatus order by LAT_PromotionalAction__r.LAT_StartDate__c) from account where Status__c != 'Cliente inativo' AND Status__c != 'Novo Cadastro' AND recordtype.developerName = 'On_Trade' AND Regional__r.name in: Regions];
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
                        if(tieneFoco(acc, listYearMonth[i + 1])){
                            vol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        }else{
                            nVol += accVolumen.get(key) == null ? 0 : accVolumen.get(key);
                        }
                    }
                    if(i > 0){
                        String lastMonthkey =  acc.id + '' + listYearMonth[i-1].month() + '/' + listYearMonth[i-1].year();
                        if(tieneFoco(acc, listYearMonth[i])){
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
                system.debug('date------->' + wrVolAtivado.wdates[i]);
                system.debug('i------->' + wrVolAtivadoValues[i]);
                system.debug('i-1------->' + wrVolAtivadoValues[i-1]);
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
    
    public PageReference doChangeDate(){
        reloadBrands();
        return null;
    }


    //Metodo que recalcula las Marcas segun las Categorias
    private void reloadBrands(){

        mapCategoryBrands = getCategoryBrands(planDesde, planHasta, isAnalitic);

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
        system.debug('&&&& ' + isAnalitic);
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
                        if (!isAnalitic) {
                            wrapReportRow wra = (wrapReportRow)parser.readValueAs(wrapReportRow.class);
                            listWrapersNew.add(wra);
                        } else {
                            wrapAnaliticReportRow wra = (wrapAnaliticReportRow)parser.readValueAs(wrapAnaliticReportRow.class);
                            listWrapersAnaliticNew.add(wra);
                        }
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
        system.debug('&&&& ' + isAnalitic);
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
                        if (!isAnalitic) {
                            wrapReportRow wra = (wrapReportRow)parser.readValueAs(wrapReportRow.class);
                            listWrapersNew.add(wra);
                        } else {
                            wrapAnaliticReportRow wra = (wrapAnaliticReportRow)parser.readValueAs(wrapAnaliticReportRow.class);
                            listWrapersAnaliticNew.add(wra);
                        }
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