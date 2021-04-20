/*************************************************************************************************
*                                         Company: ValueNet                                      *
*------------------------------------------------------------------------------------------------*
*           Controlador del la Visualforce page LAT_BR_VFP08_BalanceROI                          *
*************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 18/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_VFC08_BalanceROI {

    /*********************************************************/                                                         
    /*               VARIABLES GLOBALES                      */                                                         
    /*********************************************************/
    public List<wrapFilter> pdfFilters {get;Set;}
    public List<Region> regions {get;set;}
    public String reportName {get;set;}
    public string renderAs {get;Set;}
    public Boolean ran {get;Set;}
    
    // Filtros
    public List<SelectOption> statusSelected {get;set;}
    public string fiscalYear {get;set;}
    public string month {get;set;}
    
    public List<String> segmentatinsSelectedList {get;set;}
    public List<SelectOption> segmentsSelected {get;set;}
    public List<SelectOption> regionsSelected {get;set;}
    public List<String> regionsSelectedList {get;set;}
    public Boolean hasAccess {get;set;}
    
    private Map<String, Set<Id>> mapSchedulerC_Products; 
    private Map<Id, List<Produto_Concorr_ncia__c>> mapAccId_ProductosPRC;
    private Map<String, Informacoes_de_Custo_do_Produto__c> mapKeyICP;
    private List<LAT_Contract__c>  totalContracts;
    private Date fechaFiltro;
    private Date filterStartDate;
    private Date filterEndDate;
    private Set<Id> accIds;
    
    private List<LAT_BR_CS002_Status__c> status;
    public List<String> statusList {get;set;} 
    
    private Map<String, List<LAT_Contract__c>> mapRegSeg_Contracts;
    private Map<String, List<Decimal>> mapRegSeg_RoiCasa;
    private Map<String, String> mapCamposCantPeriodo = new Map<String, String>{ 'Havana_Club_Anejo_Reserva_periodo__c' => 'ROI_GMDC_Havana_Club_Anejo_Reserva__c',
                                                                                'Perrier_Jouet_periodo__c' => 'ROI_GMDC_Perrier_Jouet__c',
                                                                                'Perrier_Jouet_1_5L_periodo__c' => 'ROI_GMDC_Perrier_Jouet_1_5L__c',
                                                                                'Montilla_Cristal_periodo__c' => 'ROI_GMDC_Montilla_Cristal__c',
                                                                                'Havana_Club_7_anos_periodo__c' => 'ROI_GMDC_Havana_Club_7_anos__c',
                                                                                'Wall_Street_periodo__c' => 'ROI_VMA_Wall_Street__c',
                                                                                'Havana_Club_3_Anos_periodo__c' => 'ROI_GMDC_Havana_Club_3_Anos__c',
                                                                                'Kahlua_periodo__c' => 'ROI_GMDC_Kahlua__c',
                                                                                'Jim_Beam_Black_periodo__c' => 'ROI_GMDC_Jim_Beam_Black__c',
                                                                                'Jameson_Standard_periodo__c' => 'ROI_GMDC_Jameson_Standard__c',
                                                                                'Orloff_periodo__c' => 'ROI_VMA_Orloff__c',
                                                                                'Jim_Beam_White_periodo__c' => 'ROI_GMDC_Jim_Beam_White__c',
                                                                                'Perrier_Jouet_Belle_Epoque_periodo__c'  => 'ROI_VMA_Perrier_Jouet_Belle_Epoque__c',
                                                                                'Passport_LBS_periodo__c' => 'ROI_VMA_Passport_LBS__c',
                                                                                'Olmeca_periodo__c' => 'ROI_VMA_Olmeca__c',
                                                                                'Natu_Nobilis_periodo__c' => 'ROI_VMA_Natu_Nobilis__c',
                                                                                'Absolut_Vodka_periodo__c' => 'ROI_GMDC_Absolut_Vodka__c',
                                                                                'Absolut_Flavors_periodo__c' => 'ROI_GMDC_Absolut_Flavors__c',
                                                                                'Mumm_Espumante_periodo__c' => 'ROI_VMA_Mumm_Espumante__c',
                                                                                'Cachaca_Janeiro_periodo__c' => 'ROI_GMDC_Cachaca_Janeiro__c',
                                                                                'Perrier_Jouet_Belle_Epq1_5L_periodo__c' => 'ROI_VMA_Perrier_Jouet_Belle_Epq1_5L__c',
                                                                                'Mumm_Champagne_periodo__c' => 'ROI_VMA_Mumm_Champagne__c',
                                                                                'Absolut_Elyx_periodo__c' => 'ROI_GMDC_Absolut_Elyx__c',
                                                                                'Malibu_Nacional_periodo__c' => 'ROI_GMDC_Malibu_Nacional__c',
                                                                                'Wyborowa_Exquisite_periodo__c' => 'ROI_GMDC_Wyborowa_Exquisite__c',
                                                                                'Absolut_100_periodo__c' => 'ROI_GMDC_Absolut_100__c',
                                                                                'Domecq_Tradicional_periodo__c' => 'ROI_GMDC_Domecq_Tradicional__c',
                                                                                'Royal_Salute_38YO_periodo__c' => 'ROI_GMDC_Royal_Salute_38YO__c',
                                                                                'Royal_Salute_periodo__c' => 'ROI_GMDC_Royal_Salute__c',
                                                                                'Chivas_Regal_18_Years_periodo__c' => 'ROI_GMDC_Chivas_Regal_18_Years__c',
                                                                                'Ballantines_Finest_periodo__c' => 'ROI_GMDC_Ballantine_s_Finest__c',
                                                                                'Cachaca_Sao_Francisco_periodo__c' => 'ROI_GMDC_Cachaca_Sao_Francisco__c',
                                                                                'Sandeman_periodo__c' => 'ROI_GMDC_Sandeman__c',
                                                                                'Teachers_periodo__c' => 'ROI_GMDC_Teachers__c',
                                                                                'Chivas_Regal_12_Years_periodo__c' => 'ROI_GMDC_Chivas_Regal_12_Years__c',
                                                                                'Ballantines_30Y_periodo__c' => 'ROI_GMDC_Ballantine_s_30Y__c',
                                                                                'Ballantines_21Y_periodo__c' => 'ROI_GMDC_Ballantine_s_21Y__c',
                                                                                'Ballantines_17Y_periodo__c' => 'ROI_GMDC_Ballantine_s_17Y__c',
                                                                                'Tezon_periodo__c' => 'ROI_NetSales_Tezon__c',
                                                                                'Ballantines_12Y_periodo__c' => 'ROI_GMDC_Ballantine_s_12Y__c',
                                                                                'Chivas_Regal_25_Years_periodo__c' => 'ROI_GMDC_Chivas_Regal_25_Years__c'}; 
                                                                                   
    private Map<String, String> mapCamposVolumen = new Map<String, String>{ 'Havana_Club_Anejo_Reserva_periodo__c' => 'Volume_Havana_Club_Anejo_Reserva__c',
                                                                            'Perrier_Jouet_periodo__c' => 'Volume_Perrier_Jouet__c',
                                                                            'Perrier_Jouet_1_5L_periodo__c' => 'Volume_Perrier_Jouet_1_5L__c',
                                                                            'Montilla_Cristal_periodo__c' => 'Volume_Montilla_Cristal__c',
                                                                            'Havana_Club_7_anos_periodo__c' => 'Volume_Havana_Club_7_anos__c',
                                                                            'Wall_Street_periodo__c' => 'Volume_Wall_Street__c',
                                                                            'Havana_Club_3_Anos_periodo__c' => 'Volume_Havana_Club_3_Anos__c',
                                                                            'Kahlua_periodo__c' => 'Volume_Kahlua__c',
                                                                            'Jim_Beam_Black_periodo__c' => 'Volume_Jim_Beam_Black__c',
                                                                            'Jameson_Standard_periodo__c' => 'Volume_Jameson_Standard__c',
                                                                            'Orloff_periodo__c' => 'Volume_Orloff__c',
                                                                            'Jim_Beam_White_periodo__c' => 'Volume_Jim_Beam_White__c',
                                                                            'Perrier_Jouet_Belle_Epoque_periodo__c'  => 'Volume_Perrier_Jouet_Belle_Epoque__c',
                                                                            'Passport_LBS_periodo__c' => 'Volume_Passport_LBS__c',
                                                                            'Olmeca_periodo__c' => 'Volume_Olmeca__c',
                                                                            'Natu_Nobilis_periodo__c' => 'Volume_Natu_Nobilis__c',
                                                                            'Absolut_Vodka_periodo__c' => 'Volume_Absolut_Vodka__c',
                                                                            'Absolut_Flavors_periodo__c' => 'Volume_Absolut_Flavors__c',
                                                                            'Mumm_Espumante_periodo__c' => 'Volume_Mumm_Espumante__c',
                                                                            'Cachaca_Janeiro_periodo__c' => 'Volume_Cachaca_Janeiro__c',
                                                                            'Perrier_Jouet_Belle_Epq1_5L_periodo__c' => 'Volume_Perrier_Jouet_Belle_Epq1_5L__c',
                                                                            'Mumm_Champagne_periodo__c' => 'Volume_Mumm_Champagne__c',
                                                                            'Absolut_Elyx_periodo__c' => 'Volume_Absolut_Elyx__c',
                                                                            'Malibu_Nacional_periodo__c' => 'Volume_Malibu_Nacional__c',
                                                                            'Wyborowa_Exquisite_periodo__c' => 'Volume_Wyborowa_Exquisite__c',
                                                                            'Absolut_100_periodo__c' => 'Volume_absolut_100__c',
                                                                            'Domecq_Tradicional_periodo__c' => 'Volume_Domecq_Tradicional__c',
                                                                            'Royal_Salute_38YO_periodo__c' => 'Volume_Royal_Salute_38YO__c',
                                                                            'Royal_Salute_periodo__c' => 'Volume_Royal_Salute__c',
                                                                            'Chivas_Regal_18_Years_periodo__c' => 'Volume_Chivas_Regal_18_Years__c',
                                                                            'Ballantines_Finest_periodo__c' => 'Volume_Ballantine_s_Finest__c',
                                                                            'Cachaca_Sao_Francisco_periodo__c' => 'Volume_Cachaca_Sao_Francisco__c',
                                                                            'Sandeman_periodo__c' => 'Volume_Sandeman__c',
                                                                            'Teachers_periodo__c' => 'Volume_Teachers__c',
                                                                            'Chivas_Regal_12_Years_periodo__c' => 'Volume_Chivas_Regal_12_Years__c',
                                                                            'Ballantines_30Y_periodo__c' => 'Volume_Ballantines_30Y__c',
                                                                            'Ballantines_21Y_periodo__c' => 'Volume_Ballantines_21Y__c',
                                                                            'Ballantines_17Y_periodo__c' => 'Volume_Ballantines_17Y__c',
                                                                            'Tezon_periodo__c' => 'Volume_Tezon__c',
                                                                            'Ballantines_12Y_periodo__c' => 'Volume_Ballantine_s_12Y__c',
                                                                            'Chivas_Regal_25_Years_periodo__c' => 'Volume_Chivas_Regal_25_Years__c'};                                                                                                                            
    
    private Map<String, Integer> mapMeses = new Map<String, Integer>();    
    private Map<String, String> mapMnameMnumber = new Map<String, String>();
                                                                        
    public class wrapFilter{
        public string region {get;Set;}
        public string segment {get;Set;}
        wrapFilter(){}
    }                                                                        
    
    /*********************************************************/                                                         
    /*                  CONSTRUCTOR                          */                                                         
    /*********************************************************/
    public LAT_BR_VFC08_BalanceROI () {
        
        ran = false;
        regionsSelected = new List<SelectOption>();
        segmentsSelected = new List<SelectOption>();
        status = [SELECT Id, Name FROM LAT_BR_CS002_Status__c];
        statusList = new List<String>(); 
        hasAccess = false;
        string idFromReport = ApexPages.currentPage().getParameters().get('IdRep');
        
        LAT_CRP_Custom_Report__c crp;
        try {
            crp = [SELECT Id, LAT_VisualForceName__c, LAT_ReportName__c FROM LAT_CRP_Custom_Report__c WHERE id =: idFromReport];
        } catch(Exception e){}
        
        if(crp != null && crp.LAT_VisualForceName__c == 'LAT_BR_VFP08_BalanceROI'){
            hasAccess = true;
            reportName = crp.LAT_ReportName__c;
        }else{
            return;
        }
        
        // Meses
        
        List<Schema.PicklistEntry> meses = Planejamento__c.M_s_de_Ref_rencia__c.getDescribe().getPicklistValues();
        
        integer numeroMes;
        
        for (numeroMes = 1; numeroMes <= 12; numeroMes++) {        
            string nombreMes = string.valueof(meses.get(numeroMes-1).getValue());
            mapMeses.put(nombreMes, numeroMes);
            mapMnameMnumber.put(string.valueof(numeroMes), nombreMes);        
        }
        
        // Status
        for (LAT_BR_CS002_Status__c s : status) {
            statusList.add(s.Name);
        }
    
    }
    
    /*********************************************************/                                                         
    /*              EJECUCION DEL REPORTE                    */                                                         
    /*********************************************************/
    
    public void runReport() { 
        
        fechaFiltro = Date.newInstance(Integer.ValueOf(fiscalYear), Integer.ValueOf(Month), 1);                
        filterStartDate = Date.newInstance(Integer.ValueOf(fiscalYear), 1, 1);
        filterEndDate = Date.newInstance(Integer.ValueOf(fiscalYear), Integer.ValueOf(month), 1).addMonths(1).addDays(-1);
        
        boolean calculateAll = false;
        
        // REGIONES //         
        regionsSelectedList = new List<String>();                        
        Set<String> regionsToShowList = new Set<String>();
        if(regionsSelected.Size() > 0){
            for( SelectOption s : regionsSelected ){
                regionsSelectedList.add( s.getValue() );
                regionsToShowList.add( s.getValue() );
                if (s.getValue() == 'Brasil') {
                    calculateAll = true;
                }
            }
        }
        
        if (calculateAll) {
            regionsSelectedList.clear();
            for( SelectOption s : getRegionsAvailable() ){
                regionsSelectedList.add( s.getLabel() );
            }
        }
        
        // SEGMENTACIONES //
        segmentatinsSelectedList = new List<String>();         
        if(segmentsSelected.Size() > 0){
            for( SelectOption s : segmentsSelected ){
                segmentatinsSelectedList.add( s.getLabel() );
            }
        }
        
        if (regionsSelectedList.isEmpty() && segmentatinsSelectedList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LAT_BR_VFC08_00001));
            //Label.LAT_BR_VFC08_00001 = 'Tem que selecionar uma região e segmentação'
            return;
        } else if (regionsSelectedList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LAT_BR_VFC08_00002));
            //Label.LAT_BR_VFC08_00002 = 'Tem que selecionar uma segmentação'
            return;
        } else if (segmentatinsSelectedList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.LAT_BR_VFC08_00003));
            //Label.LAT_BR_VFC08_00003 = 'Tem que selecionar uma região'
            return;
        }
        
        ran = true;
        Map<String, Integer> mapPC = proposedContracts();
        Map<String, Integer> mapAC = ActualContract();
        TotalContract();
        Map<String, Integer> mapC = Coletas();
        Map<String, List<Decimal>> mapRoiPrevisto = roiProvisto();
        Map<String, List<Decimal>> mapRoiContratoReal = roiContratoReal();
        regions = new List<Region>();
        
        //partial totals for brasil (by region)
        map <string, Integer> mapTotalProposedContracts = new map <string, integer>();
        map <string, Integer> mapTotalnumberCurrentContracts = new map <string, integer>();
        map <string, integer> mapTotalConPlanRegBrasil = new map <string, integer>();
        map <string, integer> mapTotalConRegBrasil = new map <string, integer>();
        map <string, Decimal> mapTotalRoiVariationRegBrasil = new map <string, Decimal>();
        map <string, Integer> mapTotalCollect = new map <string, integer>();
        map <string, Decimal> mapTotalCMRegBrasil = new map <string, Decimal>();
        map <string, Decimal> mapTotalInvRegBrasil = new map <string, Decimal>();
        map <string, Decimal> mapTotalRoiContractABrasil = new map <string, Decimal>();
        map <string, Decimal> mapTotalRoiContractBBrasil = new map <string, Decimal>();
        map <string, Decimal> mapTotalRoiCasaABrasil = new map <string, Decimal>();
        map <string, Decimal> mapTotalRoiCasaBBrasil = new map <string, Decimal>();
        
        //all totals for brasil
        integer totalProposedContracts = 0;
        integer totalnumberCurrentContracts = 0;
        integer totalConPlanRegBrasil = 0;
        integer totalConRegBrasil = 0;
        Decimal totalRoiVariationRegBrasil = 0;
        integer totalCollect = 0;
        Decimal totalCMRegBrasil = 0;
        Decimal totalInvRegBrasil = 0;
        Decimal totalRoiContractABrasil = 0;
        Decimal totalRoiContractBBrasil = 0;
        Decimal totalRoiCasaABrasil = 0;
        Decimal totalRoiCasaBBrasil = 0;
        
        for ( String reg : regionsSelectedList ) {
            Region r = new Region();
            r.name = reg;
            r.segments = new List<Segment>();
            integer totalConPlanReg = 0;
            integer totalConReg = 0;
            Decimal totalRoiVariationReg = 0;
            Decimal totalCMReg = 0;
            Decimal totalInvReg = 0;
            Decimal totalRoiContractA = 0;
            Decimal totalRoiContractB = 0;
            Decimal totalRoiCasaA = 0;
            Decimal totalRoiCasaB = 0;
            for( String seg : segmentatinsSelectedList ) {
                String key = reg + ' | ' + seg;
                if (reg == 'Brasil') {
                    segment s = new Segment();
                    s.sName = seg;
                    s.proposedContracts = mapTotalProposedContracts.get(seg);
                    s.numberCurrentContracts = mapTotalnumberCurrentContracts.get(seg); 
                    s.diversionNumberContractsVsPlan = 0;
                    if (mapTotalConPlanRegBrasil.containsKey(seg)) {
                        s.diversionNumberContractsVsPlan = mapTotalConPlanRegBrasil.get(seg);
                    } 
                    s.totalContracts = mapTotalConRegBrasil.get(seg); 
                    s.sCollect = mapTotalCollect.get(seg);
                    s.roiPredicted = 0;
                    if (mapTotalCMRegBrasil.containsKey(seg) && mapTotalInvRegBrasil.containsKey(seg) && mapTotalInvRegBrasil.get(seg) != 0) {
                        s.roiPredicted = ((mapTotalCMRegBrasil.get(seg) - mapTotalInvRegBrasil.get(seg)) / mapTotalInvRegBrasil.get(seg)) * 100;
                    }
                    s.roiContract = 0;
                    if (mapTotalRoiContractABrasil.containsKey(seg) && mapTotalRoiContractBBrasil.containsKey(seg) && mapTotalRoiContractBBrasil.get(seg) != 0) {
                        s.roiContract = ((mapTotalRoiContractABrasil.get(seg) - mapTotalRoiContractBBrasil.get(seg)) / mapTotalRoiContractBBrasil.get(seg)) * 100;
                    }
                    s.roiHouse = 0;
                    if (mapTotalRoiCasaABrasil.containsKey(seg) && mapTotalRoiCasaBBrasil.containsKey(seg) && mapTotalRoiCasaBBrasil.get(seg) != 0) {
                        s.roiHouse = ((mapTotalRoiCasaABrasil.get(seg) - mapTotalRoiCasaBBrasil.get(seg)) / mapTotalRoiCasaBBrasil.get(seg)) * 100;
                    }

                    Decimal roiVariation = 0;
                    if (mapTotalRoiVariationRegBrasil.containsKey(seg)) {
                        roiVariation = mapTotalRoiVariationRegBrasil.get(seg);
                    } 
                    system.debug('roiVariation: ' + roiVariation);
                    s.roiVariation = (roiVariation.round(system.roundingMode.HALF_UP)); 
                    r.segments.add(s);
                    
                } else {
                    segment s = new Segment();
                    s.sName = seg;
                    s.proposedContracts = mapPC.containsKey(key) ? mapPC.get(key) : 0;
                    totalProposedContracts += s.proposedContracts;
                    if (mapTotalProposedContracts.containsKey(seg)){
                        integer currentValue = mapTotalProposedContracts.get(seg);
                        mapTotalProposedContracts.put(seg, currentValue + s.proposedContracts);
                    } else {
                        mapTotalProposedContracts.put(seg, s.proposedContracts);
                    }
                    s.numberCurrentContracts = mapAC.containsKey(key) ? mapAC.get(key) : 0;
                    totalnumberCurrentContracts += s.numberCurrentContracts;
                    if (mapTotalnumberCurrentContracts.containsKey(seg)){
                        integer currentValue = mapTotalnumberCurrentContracts.get(seg);
                        mapTotalnumberCurrentContracts.put(seg, currentValue + s.numberCurrentContracts);
                    } else {
                        mapTotalnumberCurrentContracts.put(seg, s.numberCurrentContracts);
                    }
                    s.diversionNumberContractsVsPlan = s.numberCurrentContracts - s.proposedContracts ; 
                    totalConPlanReg += s.diversionNumberContractsVsPlan;
                    totalConPlanRegBrasil += s.diversionNumberContractsVsPlan;
                    if (mapTotalConPlanRegBrasil.containsKey(seg)){
                        integer currentTotalConPlanRegBrasil = mapTotalConPlanRegBrasil.get(seg);
                        mapTotalConPlanRegBrasil.put(seg, currentTotalConPlanRegBrasil + s.diversionNumberContractsVsPlan);
                    } else {
                        mapTotalConPlanRegBrasil.put(seg, s.diversionNumberContractsVsPlan);
                    }
                    s.totalContracts = mapRegSeg_Contracts.containsKey(key) ? mapRegSeg_Contracts.get(key).size() : 0; 
                    totalConReg += s.totalContracts;
                    totalConRegBrasil += s.totalContracts;
                    if (mapTotalConRegBrasil.containsKey(seg)){
                        integer currentValue = mapTotalConRegBrasil.get(seg);
                        mapTotalConRegBrasil.put(seg, currentValue + s.totalContracts);
                    } else {
                        mapTotalConRegBrasil.put(seg, s.totalContracts);
                    }
                    s.sCollect = mapC.containsKey(key) ? mapC.get(key) : 0; 
                    totalCollect += s.sCollect;
                    if (mapTotalCollect.containsKey(seg)){
                        integer currentValue = mapTotalCollect.get(seg);
                        mapTotalCollect.put(seg, currentValue + s.sCollect);
                    } else {
                        mapTotalCollect.put(seg, s.sCollect);
                    }
                    s.roiPredicted = 0;                    
                    if (mapRoiPrevisto.containsKey(key)) {
                        List<Decimal> datos = mapRoiPrevisto.get(key);
                        Decimal cm = datos.get(0);
                        Decimal inv = datos.get(1); 
                        totalCMReg += cm;
                        totalInvReg += inv;
                        totalCMRegBrasil += cm;
                        if (mapTotalCMRegBrasil.containsKey(seg)){
                            decimal currentTotalCMRegBrasil = mapTotalCMRegBrasil.get(seg);
                            mapTotalCMRegBrasil.put(seg, currentTotalCMRegBrasil + cm);
                        } else {
                            mapTotalCMRegBrasil.put(seg, cm);
                        }
                        totalInvRegBrasil += inv;
                        if (mapTotalInvRegBrasil.containsKey(seg)){
                            decimal currentValue = mapTotalInvRegBrasil.get(seg);
                            mapTotalInvRegBrasil.put(seg, currentValue + inv);
                        } else {
                            mapTotalInvRegBrasil.put(seg, inv);
                        }
                        if (inv != 0) s.roiPredicted = ((cm - inv) / inv) * 100;
                    }
                    
                    s.roiContract = 0;
                    if (mapRoiContratoReal.containsKey(key) && mapRoiContratoReal.get(key)[1] != 0) {
                        
                        List<Decimal> datos = mapRoiContratoReal.get(key);
                        Decimal cm = datos.get(0);
                        Decimal inv = datos.get(1); 
                        system.debug('cm: ' + cm);
                        system.debug('inv: ' + inv);
                        s.roiContract = ((cm - inv) / inv) * 100;
                        totalRoiContractA += cm;
                        totalRoiContractB += inv;
                        totalRoiContractABrasil += cm;
                        if (mapTotalRoiContractABrasil.containsKey(seg)){
                            decimal currentValue = mapTotalRoiContractABrasil.get(seg);
                            mapTotalRoiContractABrasil.put(seg, currentValue + mapRoiContratoReal.get(key)[0]);
                        } else {
                            mapTotalRoiContractABrasil.put(seg, mapRoiContratoReal.get(key)[0]);
                        }
                        totalRoiContractBBrasil += inv;
                        if (mapTotalRoiContractBBrasil.containsKey(seg)){
                            decimal currentValue = mapTotalRoiContractBBrasil.get(seg);
                            mapTotalRoiContractBBrasil.put(seg, currentValue + inv);
                        } else {
                            mapTotalRoiContractBBrasil.put(seg, inv);
                        }
                    }
                     
                    s.roiHouse = 0;
                    if (mapRegSeg_RoiCasa.containsKey(key) && mapRegSeg_RoiCasa.get(key)[1] != 0) {
                        s.roiHouse = ((mapRegSeg_RoiCasa.get(key)[0] - mapRegSeg_RoiCasa.get(key)[1]) / mapRegSeg_RoiCasa.get(key)[1]) * 100;
                        totalRoiCasaA += mapRegSeg_RoiCasa.get(key)[0];
                        totalRoiCasaB += mapRegSeg_RoiCasa.get(key)[1];
                        totalRoiCasaABrasil += mapRegSeg_RoiCasa.get(key)[0];
                        if (mapTotalRoiCasaABrasil.containsKey(seg)){
                            decimal currentValue = mapTotalRoiCasaABrasil.get(seg);
                            mapTotalRoiCasaABrasil.put(seg, currentValue + mapRegSeg_RoiCasa.get(key)[0]);
                        } else {
                            mapTotalRoiCasaABrasil.put(seg, mapRegSeg_RoiCasa.get(key)[0]);
                        }
                        totalRoiCasaBBrasil += mapRegSeg_RoiCasa.get(key)[1];
                        if (mapTotalRoiCasaBBrasil.containsKey(seg)){
                            decimal currentValue = mapTotalRoiCasaBBrasil.get(seg);
                            mapTotalRoiCasaBBrasil.put(seg, currentValue + mapRegSeg_RoiCasa.get(key)[1]);
                        } else {
                            mapTotalRoiCasaBBrasil.put(seg, mapRegSeg_RoiCasa.get(key)[1]);
                        }
                    }
                    
                    Decimal roiVariation = s.roiHouse - s.roiPredicted;                     
                    roiVariation = (roiVariation.round(system.roundingMode.HALF_UP)); 
                    totalRoiVariationReg += roiVariation;
                    totalRoiVariationRegBrasil += roiVariation;
                    if (mapTotalRoiVariationRegBrasil.containsKey(seg)){
                        Decimal currentTotalRoiVariationRegBrasil = mapTotalRoiVariationRegBrasil.get(seg);
                        mapTotalRoiVariationRegBrasil.put(seg, currentTotalRoiVariationRegBrasil + roiVariation);
                    } else {
                        mapTotalRoiVariationRegBrasil.put(seg, roiVariation);
                    }
                    s.roiVariation = roiVariation; 
                    r.segments.add(s);
                }
            }
            
            segment s = new Segment();
            s.sName = 'Total ' + reg;
            if (reg == 'Brasil') {
                s.proposedContracts = totalProposedContracts;
                s.numberCurrentContracts = totalnumberCurrentContracts;
                s.diversionNumberContractsVsPlan = totalConPlanRegBrasil;
                s.totalContracts = totalConRegBrasil;
                s.sCollect = totalCollect;
                s.roiPredicted = 0;
                if (totalInvRegBrasil != 0) {                    
                    s.roiPredicted = ((totalCMRegBrasil - totalInvRegBrasil) / totalInvRegBrasil) * 100;
                }
                s.roiContract = 0;
                if (totalRoiContractBBrasil != 0) {
                    s.roiContract = ((totalRoiContractABrasil - totalRoiContractBBrasil) / totalRoiContractBBrasil) * 100;
                }
                s.roiHouse = 0;
                if (totalRoiCasaBBrasil != 0) {
                    s.roiHouse = ((totalRoiCasaABrasil - totalRoiCasaBBrasil) / totalRoiCasaBBrasil) * 100;
                }
                Decimal rVar = s.roiHouse - s.roiPredicted;
                s.roiVariation = rVar.round(system.roundingMode.HALF_UP);
                r.segments.add(s);
            } else {
                s.proposedContracts = mapPC.containsKey(reg) ? mapPC.get(reg) : 0; 
                s.numberCurrentContracts = mapAC.containsKey(reg) ? mapAC.get(reg) : 0; 
                s.diversionNumberContractsVsPlan = totalConPlanReg; 
                s.totalContracts = totalConReg; 
                s.sCollect = mapC.containsKey(reg) ? mapC.get(reg) : 0; 
                
                s.roiPredicted = 0;
                if (totalInvReg != 0) {
                    s.roiPredicted = ((totalCMReg - totalInvReg) / totalInvReg) * 100;
                }
                s.roiContract = 0;
                if (totalRoiContractB != 0) {
                    s.roiContract = ((totalRoiContractA - totalRoiContractB) / totalRoiContractB) * 100;
                }
                s.roiHouse = 0;
                if (totalRoiCasaB != 0) {
                    s.roiHouse = ((totalRoiCasaA - totalRoiCasaB) / totalRoiCasaB) * 100;                    
                }
                Decimal roiVariation = s.roiHouse - s.roiPredicted; 
                s.roiVariation = totalRoiVariationReg;
                system.debug('totalRoiVariationReg: ' + totalRoiVariationReg);
                r.segments.add(s);
            }
            if (regionsToShowList.contains(reg)) {
                regions.add(r);
            } 
        }
    }
    
    /*********************************************************/                                                         
    /*                    COLUMNAS                           */                                                         
    /*********************************************************/
    ////////// Columna 1: Nº contrato previsto //////
    /////////  Armamos un mapa con la cantidad de contratos previstos para un año - region - segmento /////////////        
    private Map<String, Integer> proposedContracts() {
        
        Map<String, Integer> mapRegSeg_CantContracts = new Map<String, Integer>();
        integer mes = integer.valueof(month);
        string fYear = mes <= 6 ? fiscalYear : string.valueof(integer.valueof(fiscalYear) + 1);
                
        List<LAT_BR_ContractForecast__c> listCF = [SELECT id, LAT_BR_Forecast__c, LAT_BR_Region__c, LAT_BR_Segmentation__c 
                                FROM LAT_BR_ContractForecast__c 
                                WHERE LAT_BR_Region__c IN: regionsSelectedList 
                                AND LAT_BR_Segmentation__c IN: segmentatinsSelectedList 
                                AND LAT_BR_FiscalYear__c =: fYear
                                ORDER BY LAT_BR_Region__c, LAT_BR_Segmentation__c]; 
                                
        mapRegSeg_CantContracts = new Map<String, Integer>();
        
        if (!listCF.isEmpty()) {
                   
            for(LAT_BR_ContractForecast__c cf : listCF) {
                if (!mapRegSeg_CantContracts.containsKey(cf.LAT_BR_Region__c)) {
                    mapRegSeg_CantContracts.put(cf.LAT_BR_Region__c, 0);
                }
                mapRegSeg_CantContracts.put(cf.LAT_BR_Region__c, mapRegSeg_CantContracts.get(cf.LAT_BR_Region__c) + integer.valueof(cf.LAT_BR_Forecast__c));                                                
                mapRegSeg_CantContracts.put(cf.LAT_BR_Region__c + ' | ' + cf.LAT_BR_Segmentation__c, integer.valueof(cf.LAT_BR_Forecast__c));  
            }        
        }
        return mapRegSeg_CantContracts;                                                                                                
    }            
    
    ////////// Columna 2: No CONTRATO ATUAL:  /////////////    
    private Map<String, Integer> ActualContract() {
        integer mes = integer.valueof(month);        
        // primer dia del año fiscal del filtro
        Date fyearFirstDate = mes <= 6 ? Date.newInstance(Integer.ValueOf(fiscalYear)-1, 7, 1) : Date.newInstance(Integer.ValueOf(fiscalYear), 7, 1);
        // último día del mes del filtro
        Date filterEndDate = Date.newInstance(Integer.ValueOf(fiscalYear), Integer.ValueOf(month), 1).addMonths(1).addDays(-1);  
        Map<String, Integer> mapRegSeg_CantActualContracts = new Map<String, Integer>(); 
                                                                       
               
        List<AggregateResult> listActualContracts = [SELECT COUNT(Id) total, account__r.LAT_BR_RegionalClientOnPremise__c region, account__r.Rating_segmentation_targert_market__c segment   
                                                     FROM LAT_Contract__c 
                                                     WHERE (account__r.LAT_BR_RegionalClientOnPremise__c IN: regionsSelectedList AND account__r.Rating_segmentation_targert_market__c IN: segmentatinsSelectedList) 
                                                     AND ( (StartDate__c <=: filterEndDate AND Status__c NOT IN: statusList) OR ( LAT_BR_RealValidityDate__c >: fyearFirstDate AND LAT_BR_RealValidityDate__c <=: filterEndDate AND Status__c NOT IN: statusList)) 
                                                     GROUP BY account__r.LAT_BR_RegionalClientOnPremise__c, account__r.Rating_segmentation_targert_market__c];
        
        for (AggregateResult ar : listActualContracts) {            
            String region = string.valueof(ar.get('region'));
            String segment = string.valueof(ar.get('segment')); 
            Integer total = integer.valueof(ar.get('total'));
            mapRegSeg_CantActualContracts.put(region + ' | ' + segment, total);
            if (!mapRegSeg_CantActualContracts.containsKey(region)) {
                mapRegSeg_CantActualContracts.put(region, 0);
            }
            mapRegSeg_CantActualContracts.put(region, mapRegSeg_CantActualContracts.get(region) + total);
        }
        return mapRegSeg_CantActualContracts;         
    }
     
    ////////// Columna 3: TOTAL CONTRATOS /////////////    
    private void totalContract() {
        if(!Utils.wasMigrationDone('1')) {   
     
            mapRegSeg_Contracts = new Map<String, List<LAT_Contract__c>>();
            integer mes = integer.valueof(month);        
            
            // primer dia del año fiscal del filtro
            Date fyearFirstDate = mes <= 6 ? Date.newInstance(Integer.ValueOf(fiscalYear)-1, 7, 1) : Date.newInstance(Integer.ValueOf(fiscalYear), 7, 1);
            
            // último día del mes del filtro
            Date filterEndDate = Date.newInstance(Integer.ValueOf(fiscalYear), Integer.ValueOf(month), 1).addMonths(1).addDays(-1);     
            List<String> lRegions = regionsSelectedList;
            List<String> lSegments = segmentatinsSelectedList;  
            List<String> lStatus = statusList;  
            List<String> statusList = new List<String>();                     

            String query = 'SELECT Id, LAT_Contract__c.EndDate__c, StartDate__c, Status__c, Prazo_de_prorrogacao_meses__c, LAT_BR_RealValidityDate__c,'; 
            query += 'Account__c, Account__r.LAT_BR_RegionalClientOnPremise__c, account__r.Rating_segmentation_targert_market__c, ';
            query += 'ROI_TInvestment__c, ContractTerm__c, account__r.Revenue_UF__c';                
            
            for (String c : mapCamposCantPeriodo.keySet()) {
                query += ', ' + c;
                query += ', ' + mapCamposCantPeriodo.get(c); 
            }     
            for (String c : mapCamposVolumen.values()) {
                query += ', ' + c;
            }                                
            
            query += ' FROM LAT_Contract__c'; 
            query += ' WHERE( (StartDate__c <=: filterEndDate AND Status__c NOT IN: lStatus) OR ';
            query += '(LAT_BR_RealValidityDate__c >: fyearFirstDate AND LAT_BR_RealValidityDate__c <=: filterEndDate AND Status__c NOT IN: lStatus) OR ';                    
            query += '(LAT_BR_Add_months_Report1__c >: fyearFirstDate AND LAT_BR_Add_months_Report1__c  <=: filterEndDate  AND Status__c NOT IN: lStatus) ) AND ';                     
            query += '( account__r.LAT_BR_RegionalClientOnPremise__c IN: lRegions AND account__r.Rating_segmentation_targert_market__c IN: lSegments)';                     
            
            System.debug('%%%%%%%%%%%%% filterEndDate : ' + filterEndDate +' ,  query : '+query);
            totalContracts = DataBase.query(query);
            accIds = new Set<Id>();     
            Set<String> setSchedulerC = new Set<String>();   
            mapSchedulerC_Products = new Map<String, Set<Id>>();
            if (!totalContracts.isEmpty()) {
                for (LAT_Contract__c con : totalContracts ) {               
                    accIds.add( con.Account__c );
                    if (contractSchedulersC(con) != null){ 
                        setSchedulerC.addAll(contractSchedulersC(con));
                    }
                    String key = con.account__r.LAT_BR_RegionalClientOnPremise__c + ' | ' + con.account__r.Rating_segmentation_targert_market__c;
                    if(!mapRegSeg_Contracts.containsKey(key)) {
                        mapRegSeg_Contracts.put(key, new list<LAT_Contract__c>() );
                    }
                    list <LAT_Contract__c> listNew = mapRegSeg_Contracts.get(key);
                    listNew.add(con);                    
                }     
            }
            System.debug('%%%%%%%% setSchedulerC : '+setSchedulerC);
            // 
            List<Product2> products = [SELECT Id, LAT_BR_Descricao_SchedulerC__c FROM Product2 WHERE LAT_BR_Descricao_SchedulerC__c IN: setSchedulerC AND LAT_IsRefactorProduct__c = 'Y' AND IsActive = TRUE];
            for (Product2 p : products) {
                if (!mapSchedulerC_Products.containsKey(p.LAT_BR_Descricao_SchedulerC__c)) {
                    mapSchedulerC_Products.put(p.LAT_BR_Descricao_SchedulerC__c, new Set<Id>());
                } 
                mapSchedulerC_Products.get(p.LAT_BR_Descricao_SchedulerC__c).add(p.Id);            
            }        
            
            mapAccId_ProductosPRC = new Map<Id, List<Produto_Concorr_ncia__c>>();
            
            List<Produto_Concorr_ncia__c> productosPRC = [SELECT Checklist_de_visita__r.Visita__r.Conta__c, 
                                                            Produto_PERNOD__c, 
                                                            Produto_PERNOD__r.bottles_per_box__c, 
                                                            Qtde_de_Caixas_Estoque__c,
                                                            Checklist_de_visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c,
                                                            Checklist_de_visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c,
                                                            Produto_PERNOD__r.LAT_BR_Descricao_SchedulerC__c
                                                            FROM Produto_Concorr_ncia__c 
                                                            WHERE Checklist_de_visita__r.Visita__r.Conta__c IN: accIds 
                                                            AND Checklist_de_visita__r.LAT_BR_ValidOnTradeChecklist__c = TRUE
                                                            AND Qtde_de_Caixas_Estoque__c > 0
                                                            ];
            System.debug('%%%%%%%%%%% SELECT  productosPRC : '+  [SELECT Checklist_de_visita__r.Visita__r.Conta__c, 
                                                            Produto_PERNOD__c, 
                                                            Produto_PERNOD__r.bottles_per_box__c, 
                                                            Qtde_de_Caixas_Estoque__c,
                                                            Checklist_de_visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c,
                                                            Checklist_de_visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c,
                                                            Produto_PERNOD__r.LAT_BR_Descricao_SchedulerC__c
                                                            FROM Produto_Concorr_ncia__c]);                                              
            System.debug('%%%%%%%%%%% productosPRC : '+productosPRC);
            //System.debug('%%%%%%%%%%% Checklist_de_visita__r.LAT_BR_ValidOnTradeChecklist__c : '+Checklist_de_visita__r.LAT_BR_ValidOnTradeChecklist__c);
            //System.debug('%%%%%%%%%%% Checklist_de_visita__r.Visita__r.Conta__c' + Checklist_de_visita__r.Visita__r.Conta__c);
            //System.debug('%%%%%%%%%%% Qtde_de_Caixas_Estoque__c : '+Qtde_de_Caixas_Estoque__c);
            Set<Id> productIds = new Set<Id>();
            for (Produto_Concorr_ncia__c pprc : productosPRC) {
                Id accId = pprc.Checklist_de_visita__r.Visita__r.Conta__c;
                if (!mapAccId_ProductosPRC.containsKey(accId)) {
                    mapAccId_ProductosPRC.put(accId, new List<Produto_Concorr_ncia__c>());
                }
                mapAccId_ProductosPRC.get(accId).add(pprc);
                if (pprc.Produto_PERNOD__c != null) productIds.add(pprc.Produto_PERNOD__c);
            }
            
            List<Informacoes_de_Custo_do_Produto__c> listICP = [SELECT Id, Scheduler_C__r.Descricao_SchedulerC__c, UF__c,
                                                                Scheduler_C__r.Tx_Conversao__c, CM_Case__c 
                                                                FROM Informacoes_de_Custo_do_Produto__c];
            
            mapKeyICP = new Map<String, Informacoes_de_Custo_do_Produto__c>();
            
            for (Informacoes_de_Custo_do_Produto__c ICP : listICP) {
                String key = ICP.Scheduler_C__r.Descricao_SchedulerC__c + ' | ' + ICP.UF__c;
                if (!mapKeyICP.containsKey(key)) {
                    mapKeyICP.put(key, ICP);
                }
            }
        }
        //MIGRATED 18/11/2016
        else {
            mapRegSeg_Contracts = new Map<String, List<LAT_Contract__c>>();
            integer mes = integer.valueof(month);        
            
            // primer dia del año fiscal del filtro
            Date fyearFirstDate = mes <= 6 ? Date.newInstance(Integer.ValueOf(fiscalYear)-1, 7, 1) : Date.newInstance(Integer.ValueOf(fiscalYear), 7, 1);
            
            // último día del mes del filtro
            Date filterEndDate = Date.newInstance(Integer.ValueOf(fiscalYear), Integer.ValueOf(month), 1).addMonths(1).addDays(-1);     
            List<String> lRegions = regionsSelectedList;
            List<String> lSegments = segmentatinsSelectedList;  
            List<String> lStatus = statusList;  
            List<String> statusList = new List<String>();                     

            String query = 'SELECT Id, LAT_Contract__c.EndDate__c, StartDate__c, Status__c, Prazo_de_prorrogacao_meses__c, LAT_BR_RealValidityDate__c,'; 
            query += 'Account__c, Account__r.LAT_BR_RegionalClientOnPremise__c, account__r.Rating_segmentation_targert_market__c, ';
            query += 'ROI_TInvestment__c, ContractTerm__c, account__r.Revenue_UF__c';                
            
            for (String c : mapCamposCantPeriodo.keySet()) {
                query += ', ' + c;
                query += ', ' + mapCamposCantPeriodo.get(c); 
            }     
            for (String c : mapCamposVolumen.values()) {
                query += ', ' + c;
            }                                
            
            query += ' FROM LAT_Contract__c'; 
            query += ' WHERE( (StartDate__c <=: filterEndDate AND Status__c NOT IN: lStatus) OR ';
            query += '(LAT_BR_RealValidityDate__c >: fyearFirstDate AND LAT_BR_RealValidityDate__c <=: filterEndDate AND Status__c NOT IN: lStatus) OR ';                    
            query += '(LAT_BR_Add_months_Report1__c >: fyearFirstDate AND LAT_BR_Add_months_Report1__c  <=: filterEndDate  AND Status__c NOT IN: lStatus) ) AND ';                     
            query += '( account__r.LAT_BR_RegionalClientOnPremise__c IN: lRegions AND account__r.Rating_segmentation_targert_market__c IN: lSegments)';                     
            
            totalContracts = DataBase.query(query);
            accIds = new Set<Id>();     
            Set<String> setSchedulerC = new Set<String>();   
            mapSchedulerC_Products = new Map<String, Set<Id>>();
            if (!totalContracts.isEmpty()) {
                for (LAT_Contract__c con : totalContracts ) {               
                    accIds.add( con.Account__c );
                    if (contractSchedulersC(con) != null) setSchedulerC.addAll(contractSchedulersC(con));
                    String key = con.account__r.LAT_BR_RegionalClientOnPremise__c + ' | ' + con.account__r.Rating_segmentation_targert_market__c;
                    if(!mapRegSeg_Contracts.containsKey(key)) {
                        mapRegSeg_Contracts.put(key, new list<LAT_Contract__c>() );
                    }
                    list <LAT_Contract__c> listNew = mapRegSeg_Contracts.get(key);
                    listNew.add(con);                    
                }     
            }
            
            // 
            List<LAT_Product__c> products = [SELECT Id, LAT_BR_SchedulerCDescription__c FROM LAT_Product__c WHERE LAT_BR_SchedulerCDescription__c IN: setSchedulerC AND LAT_IsRefactorProduct__c = 'Y' AND LAT_IsActive__c = TRUE];
            for (LAT_Product__c p : products) {
                if (!mapSchedulerC_Products.containsKey(p.LAT_BR_SchedulerCDescription__c)) {
                    mapSchedulerC_Products.put(p.LAT_BR_SchedulerCDescription__c, new Set<Id>());
                } 
                mapSchedulerC_Products.get(p.LAT_BR_SchedulerCDescription__c).add(p.Id);            
            }        
            
            mapAccId_ProductosPRC = new Map<Id, List<Produto_Concorr_ncia__c>>();
            
            List<Produto_Concorr_ncia__c> productosPRC = [SELECT Checklist_de_visita__r.Visita__r.Conta__c, 
                                                            LAT_Product__c, 
                                                            LAT_Product__r.LAT_BottlesPerBox__c, 
                                                            Qtde_de_Caixas_Estoque__c,
                                                            Checklist_de_visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c,
                                                            Checklist_de_visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c,
                                                            LAT_Product__r.LAT_BR_SchedulerCDescription__c
                                                            FROM Produto_Concorr_ncia__c 
                                                            WHERE Checklist_de_visita__r.Visita__r.Conta__c IN: accIds 
                                                            AND Checklist_de_visita__r.LAT_BR_ValidOnTradeChecklist__c = TRUE
                                                            AND Qtde_de_Caixas_Estoque__c > 0
                                                            ];
            Set<Id> productIds = new Set<Id>();
            for (Produto_Concorr_ncia__c pprc : productosPRC) {
                Id accId = pprc.Checklist_de_visita__r.Visita__r.Conta__c;
                if (!mapAccId_ProductosPRC.containsKey(accId)) {
                    mapAccId_ProductosPRC.put(accId, new List<Produto_Concorr_ncia__c>());
                }
                mapAccId_ProductosPRC.get(accId).add(pprc);
                if (pprc.LAT_Product__c != null) productIds.add(pprc.LAT_Product__c);
            }
            
            List<Informacoes_de_Custo_do_Produto__c> listICP = [SELECT Id, Scheduler_C__r.Descricao_SchedulerC__c, UF__c,
                                                                Scheduler_C__r.Tx_Conversao__c, CM_Case__c 
                                                                FROM Informacoes_de_Custo_do_Produto__c];
            
            mapKeyICP = new Map<String, Informacoes_de_Custo_do_Produto__c>();
            
            for (Informacoes_de_Custo_do_Produto__c ICP : listICP) {
                String key = ICP.Scheduler_C__r.Descricao_SchedulerC__c + ' | ' + ICP.UF__c;
                if (!mapKeyICP.containsKey(key)) {
                    mapKeyICP.put(key, ICP);
                }
            }            
        }
    }
    
    ////////// Columna 4: COLETA   /////////////
    private Map<String, Integer> coletas() {
   
        Map<String, Integer> mapRegSeg_CantColetas = new Map<String, Integer>();
        string mName = mapMnameMnumber.get(month);
                                
        List<Checklist_de_visita__c> listCV = [SELECT Id,
                                                (SELECT Id FROM Produtos_Concorr_ncia__r WHERE Qtde_de_Caixas_Estoque__c > 0 OR Nao_se_aplica__c = TRUE)     
                                                FROM Checklist_de_visita__c
                                                WHERE Visita__r.Conta__c IN: accIds 
                                                AND LAT_BR_ValidOnTradeChecklist__c = TRUE
                                                AND Visita__r.Planejamento__r.Ano_de_Referencia__c =: fiscalYear
                                                AND Visita__r.Planejamento__r.M_s_de_Ref_rencia__c =: mName];
        
        Set<Id> setCVIds = new Set<Id>();                                                        
        for (Checklist_de_visita__c cv : listCV) {        
            List<Produto_Concorr_ncia__c> lPPC = cv.Produtos_Concorr_ncia__r;
            if (!lPPC.isEmpty()) {
                setCVIds.add(cv.id);
            }                    
        }                                                
        
        List<AggregateResult> listColetas = [SELECT COUNT(Id) total, 
                                            Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c region, 
                                            Visita__r.Conta__r.Rating_segmentation_targert_market__c segment 
                                            FROM Checklist_de_visita__c 
                                            WHERE id IN: setCVIds 
                                            GROUP BY Visita__r.conta__r.LAT_BR_RegionalClientOnPremise__c, 
                                            Visita__r.conta__r.Rating_segmentation_targert_market__c ];
                                           
        for (AggregateResult ar : listColetas) {            
            String region = string.valueof(ar.get('region'));
            String segment = string.valueof(ar.get('segment')); 
            Integer total = integer.valueof(ar.get('total'));
            
            if (!mapRegSeg_CantColetas.containsKey(region)) {
                mapRegSeg_CantColetas.put(region, 0);
            }
            mapRegSeg_CantColetas.put(region, mapRegSeg_CantColetas.get(region) + total);
            mapRegSeg_CantColetas.put(region + ' | ' + segment, total);
        }     
        return mapRegSeg_CantColetas; 
    }
    
    ////////// Columna 5: ROI PREVISTO (CONTRATO):  /////////////
    private Map<String, List<Decimal>> roiProvisto () {
    
        Map<String, List<Decimal>> mapKeyRoiPrevisto = new Map<String, List<Decimal>>();
        system.debug('fiscalYear: ' + fiscalYear);
        system.debug('Month: ' + Month);
        //Date fechaFiltro = Date.newInstance(Integer.ValueOf(fiscalYear), Integer.ValueOf(Month), 1).addMonths(-1);              
        
        for (String regSeg : mapRegSeg_Contracts.keySet()) {
            Decimal totalCM = 0;
            Decimal totalINV = 0; 
            
            List<LAT_Contract__c> listCT = mapRegSeg_Contracts.get(regSeg); 
            
            for (LAT_Contract__c con : listCT) {
                
                if ( con.LAT_BR_RealValidityDate__c <= fechaFiltro ) {                                                         
                    for (String c : mapCamposCantPeriodo.keySet()) {
                        Decimal cantCajas = (Decimal)con.get(c);
                        String fName = mapCamposCantPeriodo.get(c);
                        String uf = con.Account__r.Revenue_UF__c;                                        
                        if (cantCajas != null && cantCajas > 0) {
                            totalCM += ContratoROI_Aux.getGMDC(cantCajas, fName, uf);
                        }       
                    }                             
                } else if(con.StartDate__c <= fechaFiltro) {
                   for (String c : mapCamposCantPeriodo.keySet()) {                         
                        Decimal cantCajas = (Decimal)con.get(c);                                                                        
                        if (cantCajas != null && cantCajas > 0) {                                                        
                            String campoVol = mapCamposVolumen.get(c);
                            Decimal volProd = (Decimal)con.get(campoVol);
                            integer cantMeses = (fechaFiltro.Month() + ((fechaFiltro.year() - con.StartDate__c.year()) * 12)) - con.StartDate__c.Month();                              
                            totalCM += ContratoROI_Aux.getGMDC(cantMeses * volProd, mapCamposCantPeriodo.get(c), con.Account__r.Revenue_UF__c);                                                                                                                                        
                        }             
                   }                     
                }
                totalINV += invContrato(con); 
            }                  
            mapKeyRoiPrevisto.put(regSeg, new List<Decimal>{totalCM, totalINV});
        }
        return mapKeyRoiPrevisto;
    }                
    
    ////////// Columna 6: ROI CONTRATO (REAL):  /////////////
    public Map<String, List<Decimal>> roiContratoReal() {

        if(!Utils.wasMigrationDone('1')) {                       
            //Date fechaFiltro = Date.newInstance(Integer.ValueOf(fiscalYear), Integer.ValueOf(month), 1).addMonths(1).addDays(-1);
            Map<String, List<Decimal>> mapRegSeg_RoiContratoReal = new Map<String, List<Decimal>>();
            mapRegSeg_RoiCasa = new Map<String, List<Decimal>>();
            
            for(String regSeg : mapRegSeg_Contracts.keySet()) {
                
                Decimal totalCMReal = 0;
                Decimal totalCMCasa = 0;
                Decimal totalINV = 0;
                
                for (LAT_Contract__c con : mapRegSeg_Contracts.get(regSeg)) {
                    totalINV += invContrato(con);
                    Set<Id> proIds = contractProducts(con);
                    if (!mapAccId_ProductosPRC.containsKey(con.Account__c)) {
                        continue;
                    }
                    
                    // El contrato esta incluido en el periodo
                    
                    if (con.LAT_BR_RealValidityDate__c <= fechaFiltro) {
                        
                        List<Produto_Concorr_ncia__c> lProd = mapAccId_ProductosPRC.get(con.Account__c);
                        
                        for (Produto_Concorr_ncia__c pprc : lProd) {
                            
                            String sMonth = pprc.Checklist_de_visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c;
                            Integer nMonth = mapMeses.get(sMonth);
                            Integer year = integer.valueof(pprc.Checklist_de_visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c);
                            Date myDate = date.newinstance(year, nMonth, 1);                                                                        
                            
                            // ROI CONTRATO (REAL)                                                                                                                 
                            if (myDate >= con.StartDate__c && myDate <= con.LAT_BR_RealValidityDate__c && proIds.contains(pprc.Produto_PERNOD__c)) {
                                String key = pprc.Produto_PERNOD__r.LAT_BR_Descricao_SchedulerC__c + ' | ' + con.Account__r.Revenue_UF__c;
                                
                                Informacoes_de_Custo_do_Produto__c ICP = mapKeyICP.get(key);
                                Decimal cantCajas = pprc.Qtde_de_Caixas_Estoque__c / pprc.Produto_PERNOD__r.bottles_per_box__c;
                                Decimal cMCase = ICP.CM_Case__c;
                                Decimal txConversao = ICP.Scheduler_C__r.Tx_Conversao__c;
                                totalCMReal += cantCajas * cMCase * txConversao;
                            }
                            
                            // ROI CASA                                                                                                                 
                            if (myDate >= con.StartDate__c && myDate <= con.LAT_BR_RealValidityDate__c && pprc.Qtde_de_Caixas_Estoque__c > 0) {
                                String key = pprc.Produto_PERNOD__r.LAT_BR_Descricao_SchedulerC__c + ' | ' + con.Account__r.Revenue_UF__c;
                                Informacoes_de_Custo_do_Produto__c ICP = mapKeyICP.get(key);
                                Decimal cantCajas = (pprc.Qtde_de_Caixas_Estoque__c == null ? 0: pprc.Qtde_de_Caixas_Estoque__c) / (pprc.Produto_PERNOD__r.bottles_per_box__c ==null ? 6 : pprc.Produto_PERNOD__r.bottles_per_box__c);
                                Decimal cMCase = ICP.CM_Case__c;
                                Decimal txConversao = ICP.Scheduler_C__r.Tx_Conversao__c;
                                totalCMCasa += cantCajas * cMCase * txConversao;
                            }
                        }                     
                        
                    } else if (con.StartDate__c <= fechaFiltro) {
                        
                        List<Produto_Concorr_ncia__c> lProd = mapAccId_ProductosPRC.get(con.Account__c);
                        integer cantMeses = (fechaFiltro.Month() + ((fechaFiltro.year() - con.StartDate__c.year()) * 12)) - con.StartDate__c.Month();
                        
                        for (Produto_Concorr_ncia__c pprc : lProd) {
                            String sMonth = pprc.Checklist_de_visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c;
                            Integer nMonth = mapMeses.get(sMonth);
                            Integer year = integer.valueof(pprc.Checklist_de_visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c);
                            if(system.test.isRunningTest() && nMonth == null){
                                nMonth = 1;
                            }
                            Date fechaPlaneamiento = date.newinstance(year, nMonth, 1);   
                            
                            // ROI CONTRATO (REAL)                                                       
                            if (fechaPlaneamiento >= con.StartDate__c && fechaPlaneamiento <= fechaFiltro && proIds.contains(pprc.Produto_PERNOD__c)) {
                                String key = pprc.Produto_PERNOD__r.LAT_BR_Descricao_SchedulerC__c + ' | ' + con.Account__r.Revenue_UF__c;
                                Informacoes_de_Custo_do_Produto__c ICP = mapKeyICP.get(key);
                                Decimal cantCajas = (pprc.Qtde_de_Caixas_Estoque__c == null ? 0: pprc.Qtde_de_Caixas_Estoque__c) / (pprc.Produto_PERNOD__r.bottles_per_box__c ==null ? 6 : pprc.Produto_PERNOD__r.bottles_per_box__c);
                                Decimal cMCase = ICP.CM_Case__c;
                                Decimal txConversao = ICP.Scheduler_C__r.Tx_Conversao__c;
                                totalCMReal += cantCajas * cMCase * txConversao;
                            }
                                                                            
                            // ROI CASA                                      
                            if (fechaPlaneamiento >= con.StartDate__c && fechaPlaneamiento <= fechaFiltro && pprc.Qtde_de_Caixas_Estoque__c > 0) {                            
                                String key = pprc.Produto_PERNOD__r.LAT_BR_Descricao_SchedulerC__c + ' | ' + con.Account__r.Revenue_UF__c;
                                Informacoes_de_Custo_do_Produto__c ICP = mapKeyICP.get(key);
                                 
                                if (ICP != null) {
                                    Decimal cantCajas = (pprc.Qtde_de_Caixas_Estoque__c == null ? 0 : pprc.Qtde_de_Caixas_Estoque__c) / (pprc.Produto_PERNOD__r.bottles_per_box__c ==null ? 6 : pprc.Produto_PERNOD__r.bottles_per_box__c);
                                    Decimal cMCase = ICP.CM_Case__c;
                                    Decimal txConversao = ICP.Scheduler_C__r.Tx_Conversao__c;
                                    totalCMCasa += cantCajas * cMCase * txConversao;
                                }
                            }
                        } 
                    }                    
                }                        
                List<Decimal> lstRoiReal = new List<Decimal>{totalCMReal, totalINV};
                List<Decimal> lstRoiCasa = new List<Decimal>{totalCMCasa, totalINV};
                mapRegSeg_RoiContratoReal.put(regSeg, lstRoiReal);
                mapRegSeg_RoiCasa.put(regSeg, lstRoiCasa);            
            }                
            return mapRegSeg_RoiContratoReal;       
        }
        //MIGRATED 18/11/2016
        else {
            //Date fechaFiltro = Date.newInstance(Integer.ValueOf(fiscalYear), Integer.ValueOf(month), 1).addMonths(1).addDays(-1);
            Map<String, List<Decimal>> mapRegSeg_RoiContratoReal = new Map<String, List<Decimal>>();
            mapRegSeg_RoiCasa = new Map<String, List<Decimal>>();
            
            for(String regSeg : mapRegSeg_Contracts.keySet()) {
                
                Decimal totalCMReal = 0;
                Decimal totalCMCasa = 0;
                Decimal totalINV = 0;
                
                for (LAT_Contract__c con : mapRegSeg_Contracts.get(regSeg)) {
                    totalINV += invContrato(con);
                    Set<Id> proIds = contractProducts(con);
                    if (!mapAccId_ProductosPRC.containsKey(con.Account__c)) {
                        continue;
                    }
                    
                    // El contrato esta incluido en el periodo
                    
                    if (con.LAT_BR_RealValidityDate__c <= fechaFiltro) {
                        
                        List<Produto_Concorr_ncia__c> lProd = mapAccId_ProductosPRC.get(con.Account__c);
                        
                        for (Produto_Concorr_ncia__c pprc : lProd) {
                            
                            String sMonth = pprc.Checklist_de_visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c;
                            Integer nMonth = mapMeses.get(sMonth);
                            Integer year = integer.valueof(pprc.Checklist_de_visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c);
                            Date myDate = date.newinstance(year, nMonth, 1);                                                                        
                            
                            // ROI CONTRATO (REAL)                                                                                                                 
                            if (myDate >= con.StartDate__c && myDate <= con.LAT_BR_RealValidityDate__c && proIds.contains(pprc.LAT_Product__c)) {
                                String key = pprc.LAT_Product__r.LAT_BR_SchedulerCDescription__c + ' | ' + con.Account__r.Revenue_UF__c;
                                
                                Informacoes_de_Custo_do_Produto__c ICP = mapKeyICP.get(key);
                                Decimal cantCajas = pprc.Qtde_de_Caixas_Estoque__c / pprc.LAT_Product__r.LAT_BottlesPerBox__c;
                                Decimal cMCase = ICP.CM_Case__c;
                                Decimal txConversao = ICP.Scheduler_C__r.Tx_Conversao__c;
                                totalCMReal += cantCajas * cMCase * txConversao;
                            }
                            
                            // ROI CASA                                                                                                                 
                            if (myDate >= con.StartDate__c && myDate <= con.LAT_BR_RealValidityDate__c && pprc.Qtde_de_Caixas_Estoque__c > 0) {
                                String key = pprc.LAT_Product__r.LAT_BR_SchedulerCDescription__c + ' | ' + con.Account__r.Revenue_UF__c;
                                Informacoes_de_Custo_do_Produto__c ICP = mapKeyICP.get(key);
                                Decimal cantCajas = (pprc.Qtde_de_Caixas_Estoque__c == null ? 0: pprc.Qtde_de_Caixas_Estoque__c) / (pprc.LAT_Product__r.LAT_BottlesPerBox__c ==null ? 6 : pprc.LAT_Product__r.LAT_BottlesPerBox__c);
                                Decimal cMCase = ICP.CM_Case__c;
                                Decimal txConversao = ICP.Scheduler_C__r.Tx_Conversao__c;
                                totalCMCasa += cantCajas * cMCase * txConversao;
                            }
                        }                     
                        
                    } else if (con.StartDate__c <= fechaFiltro) {
                        
                        List<Produto_Concorr_ncia__c> lProd = mapAccId_ProductosPRC.get(con.Account__c);
                        integer cantMeses = (fechaFiltro.Month() + ((fechaFiltro.year() - con.StartDate__c.year()) * 12)) - con.StartDate__c.Month();
                        
                        for (Produto_Concorr_ncia__c pprc : lProd) {
                            String sMonth = pprc.Checklist_de_visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c;
                            Integer nMonth = mapMeses.get(sMonth);
                            Integer year = integer.valueof(pprc.Checklist_de_visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c);
                            if(system.test.isRunningTest() && nMonth == null){
                                nMonth = 1;
                            }
                            Date fechaPlaneamiento = date.newinstance(year, nMonth, 1);   
                            
                            // ROI CONTRATO (REAL)                                                       
                            if (fechaPlaneamiento >= con.StartDate__c && fechaPlaneamiento <= fechaFiltro && proIds.contains(pprc.LAT_Product__c)) {
                                String key = pprc.LAT_Product__r.LAT_BR_SchedulerCDescription__c + ' | ' + con.Account__r.Revenue_UF__c;
                                Informacoes_de_Custo_do_Produto__c ICP = mapKeyICP.get(key);
                                Decimal cantCajas = (pprc.Qtde_de_Caixas_Estoque__c == null ? 0: pprc.Qtde_de_Caixas_Estoque__c) / (pprc.LAT_Product__r.LAT_BottlesPerBox__c ==null ? 6 : pprc.LAT_Product__r.LAT_BottlesPerBox__c);
                                Decimal cMCase = ICP.CM_Case__c;
                                Decimal txConversao = ICP.Scheduler_C__r.Tx_Conversao__c;
                                totalCMReal += cantCajas * cMCase * txConversao;
                            }
                                                                            
                            // ROI CASA                                      
                            if (fechaPlaneamiento >= con.StartDate__c && fechaPlaneamiento <= fechaFiltro && pprc.Qtde_de_Caixas_Estoque__c > 0) {                            
                                String key = pprc.LAT_Product__r.LAT_BR_SchedulerCDescription__c + ' | ' + con.Account__r.Revenue_UF__c;
                                Informacoes_de_Custo_do_Produto__c ICP = mapKeyICP.get(key);
                                 
                                if (ICP != null) {
                                    Decimal cantCajas = (pprc.Qtde_de_Caixas_Estoque__c == null ? 0 : pprc.Qtde_de_Caixas_Estoque__c) / (pprc.LAT_Product__r.LAT_BottlesPerBox__c ==null ? 6 : pprc.LAT_Product__r.LAT_BottlesPerBox__c);
                                    Decimal cMCase = ICP.CM_Case__c;
                                    Decimal txConversao = ICP.Scheduler_C__r.Tx_Conversao__c;
                                    totalCMCasa += cantCajas * cMCase * txConversao;
                                }
                            }
                        } 
                    }                    
                }                        
                List<Decimal> lstRoiReal = new List<Decimal>{totalCMReal, totalINV};
                List<Decimal> lstRoiCasa = new List<Decimal>{totalCMCasa, totalINV};
                mapRegSeg_RoiContratoReal.put(regSeg, lstRoiReal);
                mapRegSeg_RoiCasa.put(regSeg, lstRoiCasa);            
            }                
            return mapRegSeg_RoiContratoReal;  
        }    


    }  
    
    /*********************************************************/                                                         
    /*                      FILTROS                          */                                                         
    /*********************************************************/                 
    public List<SelectOption> getRegionsAvailable() {
        List<SelectOption> regionsAvailable = new List<SelectOption>();
        List<Schema.PicklistEntry> listPicklistEntry = Account.LAT_BR_RegionalClientOnPremise__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry pe : listPicklistEntry) {
            string l = pe.getLabel();
            string v = pe.getValue();
            regionsAvailable.add(new SelectOption(v,l));
        }
        regionsAvailable.add(new SelectOption('Brasil','Brasil'));
        return regionsAvailable;
    }    
    
    public List<SelectOption> getSegmentsAvailable() {
        List<SelectOption> segmentsAvailable = new List<SelectOption>();
        List<LAT_BR_CS001_Segmentacion__c> segments = [SELECT Id, Name FROM LAT_BR_CS001_Segmentacion__c];
        for (Schema.LAT_BR_CS001_Segmentacion__c s : segments) {            
            segmentsAvailable.add(new SelectOption(s.Id, s.Name));
        }
        return segmentsAvailable;
    }        
    
    public List<SelectOption> getStatusAvailable() {
        List<SelectOption> statusAvailable = new List<SelectOption>();
        List<LAT_BR_CS002_Status__c> status = [SELECT Id, Name FROM LAT_BR_CS002_Status__c];
        for (Schema.LAT_BR_CS002_Status__c s : status) {            
            statusAvailable.add(new SelectOption(s.Id, s.Name));
        }
        return statusAvailable;
    }        
    
    public List<SelectOption> getFiscalYears() {
        List<LAT_Contract__c> con = [SELECT Id, StartDate__c FROM LAT_Contract__c WHERE StartDate__c != NULL ORDER BY StartDate__c ASC LIMIT 1];
        integer actualyear = Date.Today().addMonths(-1).year();
        integer firstYear = Date.Today().year();
        if (!con.isEmpty() ) {
            firstYear = con.get(0).StartDate__c.year();
            if( firstYear > actualyear){
                actualyear = firstYear;            
            }
        }  
        List<SelectOption> fiscalYears = new List<SelectOption>();
        for ( integer i = firstYear;  i <= actualyear; i++ ) {
            fiscalYears.add(new SelectOption(String.ValueOf(i), String.ValueOf(i)));     
        }
      
        return fiscalYears;    
    }        
    
    public List<SelectOption> getMonths() {
        
        List<SelectOption> months = new List<SelectOption>();        
        List<Schema.PicklistEntry> listMonths = Planejamento__c.M_s_de_Ref_rencia__c.getDescribe().getPicklistValues();        
        Integer actualYear = Date.Today().year();
        Integer actualMonth = Date.Today().month();
        
        if ( fiscalYear == String.valueOf(actualYear ) ) {
            for ( integer i = 1; i < actualMonth; i++) {            
                months.add(new SelectOption(String.valueOf(i-1), listMonths[i-1].getLabel()));
            }
        } else {
            for (integer i = 0 ; i <= listMonths.Size()-1 ; i++ ) {               
                months.add(new SelectOption(String.valueOf(i+1), listMonths[i].getLabel()));
            }  
        }
        return months;
   
    }
    
    /*********************************************************/                                                         
    /*                  METODOS AXILIARES                    */                                                         
    /*********************************************************/
    private Decimal invContrato(LAT_Contract__c contrato) {                        
        
        if( contrato.LAT_BR_RealValidityDate__c <= fechaFiltro ) {
            return contrato.ROI_TInvestment__c;
        } else if( fechaFiltro >= contrato.StartDate__c ) {                                    
            integer cantMeses = (fechaFiltro.Month() + ((fechaFiltro.year() - contrato.StartDate__c.year()) * 12)) - contrato.StartDate__c.Month();                              
            return (contrato.ROI_TInvestment__c / contrato.ContractTerm__c) * cantMeses;           
        }      
        return 0;
    }        
    
    private Set<String> contractSchedulersC (LAT_Contract__c contract) {
        Set<String> conSchedulersC = new Set<String>(); 
        for (String c : mapCamposCantPeriodo.KeySet() ) {
            Decimal val = (Decimal)contract.get(c);          
            if (val != null && val > 0) {            
                Informacoes_de_Custo_do_Produto__c ICP = ContratoROI_Aux.getICP( mapCamposCantPeriodo.get(c) , contract.Account__r.Revenue_UF__c);
                if (ICP != null && ICP.Scheduler_C__c != null && ICP.Scheduler_C__r.Descricao_SchedulerC__c != null) {
                    conSchedulersC.add(ICP.Scheduler_C__r.Descricao_SchedulerC__c);
                }                    
            }                       
        }
        return conSchedulersC;
    }
    
    private Set<Id> contractProducts (LAT_Contract__c contract) {
        Set<Id> productIds = new Set<Id>(); 
        for (String c : mapCamposCantPeriodo.KeySet() ) {
            Decimal val = (Decimal)contract.get(c);          
            if (val != null && val > 0) {            
                Informacoes_de_Custo_do_Produto__c ICP = ContratoROI_Aux.getICP(mapCamposCantPeriodo.get(c), contract.Account__r.Revenue_UF__c);                
                if (ICP != null && ICP.Scheduler_C__c != null && ICP.Scheduler_C__r.Descricao_SchedulerC__c != null && mapSchedulerC_Products.containsKey(ICP.Scheduler_C__r.Descricao_SchedulerC__c)) {
                    productIds.addAll(mapSchedulerC_Products.get(ICP.Scheduler_C__r.Descricao_SchedulerC__c));
                }                    
            }                       
        }
        return productIds;
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
    
    /*********************************************************/                                                         
    /*                  CLASES AUXILIARES                    */                                                         
    /*********************************************************/

    public class Region {
        public string name {get;set;}
        public List<Segment> segments {get;set;}
    }        
    
    public class Segment {
        public string sName {get;set;}
        public integer proposedContracts {get;set;}
        public integer numberCurrentContracts {get;set;}
        public integer diversionNumberContractsVsPlan {get;set;}
        public integer totalContracts {get;set;}
        public integer sCollect {get;set;}
        public decimal roiPredicted {get;set;}
        public decimal roiContract {get;set;}
        public decimal roiHouse {get;set;}
        public decimal roiVariation {get;set;}
    }  
    
    /*********************************************************/                                                         
    /*                  COMO SE RENDERIZA                    */                                                         
    /*********************************************************/
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
       List<Integer> listSizes = new List<Integer>{regionsSelected.size(), segmentsSelected.size()};
       listSizes.sort();
       for(Integer i=0; i<listSizes[1]; i++){
           wrapFilter wf = new wrapFilter();
           try{wf.region = regionsSelected[i].getValue();}catch(Exception e){}
           try{wf.segment = segmentsSelected[i].getLabel();}catch(Exception e){}
           pdfFilters.add(wf);
       }
   }
}