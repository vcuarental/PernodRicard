/******************************************************************************
*                           Company: Zimmic
*------------------------------------------------------------------------------
*  Controladora de la VFP LAT_BR_VFP28_SellOutCollect
*******************************************************************************/
public with sharing class LAT_BR_SellOutCollect {

    // Constants used across the class
    private static final String currentYear = String.valueOf(Date.today().year());
    private static final String currentMonth = String.valueOf(Date.today().month());
    private static final String profileName = [SELECT id, Name FROM Profile WHERE id =: userInfo.getProfileId()].Name;
    private static final Map<Integer, String> monthList = LAT_BR_SellOutTaskCreator.getMonthMap();


    // Filter Variables
    public LAT_SellOutCollect__c client {get; set;}
    public Account dummyOwner {get; set;}
    public String month {get; set;}
    public String year {get; set;}


    // List of Header Objects to display
    public List<SellOutCollectHeader> headerList {get; set;}

    // Filling Coleta for current month
    private LAT_SellOutCollect__c fillingColeta {get; set;}
    private Boolean enableDeleting {get; set;}
    public Boolean allowWebEdit {get; set;}

    // Map to get month from numbers
    

    // Constructor
    public LAT_BR_SellOutCollect() {
        // Variable initialization
        this.headerList = new List<SellOutCollectHeader>();
        this.client = new LAT_SellOutCollect__c();
        this.fillingColeta = new LAT_SellOutCollect__c();
        this.dummyOwner = new Account();
        this.dummyOwner.Area_Manager__c = userInfo.getUserId();

        this.month = currentMonth;
        this.year = currentYear;
        allowWebEdit = true;

        if (profileName.contains('Administrator')) {
        	this.enableDeleting = true;
        } 

        if(Utils.isPartOfMobileCRM(UserInfo.getUserId())){
            allowWebEdit = false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, label.LAT_VFP30_Mobile_Permissions_Sellout);
            ApexPages.addMessage(myMsg);
        }
    }

    // Gets the month list to be diplay in Month picklist
    public List<SelectOption> getMonthsList() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('1',Label.LAT_January));
        options.add(new SelectOption('2',Label.LAT_February));
        options.add(new SelectOption('3',Label.LAT_March));
        options.add(new SelectOption('4',Label.LAT_April));
        options.add(new SelectOption('5',Label.LAT_May));
        options.add(new SelectOption('6',Label.LAT_June));
        options.add(new SelectOption('7',Label.LAT_July));
        options.add(new SelectOption('8',Label.LAT_August));
        options.add(new SelectOption('9',Label.LAT_September));
        options.add(new SelectOption('10',Label.LAT_October));
        options.add(new SelectOption('11',Label.LAT_November));
        options.add(new SelectOption('12',Label.LAT_December));
        
        return options;
    }
    // Gets the year list to be diplay in year picklist
    public List<SelectOption> getYearList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('2009','2009'));
        options.add(new SelectOption('2010','2010'));
        options.add(new SelectOption('2011','2011'));
        options.add(new SelectOption('2012','2012'));
        options.add(new SelectOption('2013','2013'));
        options.add(new SelectOption('2014','2014'));
        options.add(new SelectOption('2015','2015'));
        options.add(new SelectOption('2016','2016'));
        options.add(new SelectOption('2017','2017'));
        options.add(new SelectOption('2018','2018'));
        options.add(new SelectOption('2019','2019'));
        options.add(new SelectOption('2020','2020'));
        options.add(new SelectOption('2021','2021'));
        options.add(new SelectOption('2022','2022'));
        options.add(new SelectOption('2023','2023'));
        options.add(new SelectOption('2024','2024'));
        options.add(new SelectOption('2025','2025'));
        options.add(new SelectOption('2026','2026'));
        options.add(new SelectOption('2027','2027'));
        options.add(new SelectOption('2028','2028'));
        options.add(new SelectOption('2029','2029'));
        options.add(new SelectOption('2030','2030'));
        
        return options;
    }

    // Validates that all the required information is present
    public void doSearch() {
        // Client and year fitlers can not be null
        // Month will never be null as it's a picklist with a default value.
        if (this.year != null && this.year != '') {
            this.headerList = getHeaders(); 
        } else {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Favor informar o Mês e Ano para Pesquisar.'); 
            ApexPages.addMessage(errorMsg);
        }
         
    }


    // Get the list of the headers 
    private List<SellOutCollectHeader> getHeaders() {
        List<SellOutCollectHeader> result = new List<SellOutCollectHeader>();

        List<LAT_SellOutCollect__c> coletas = new List<LAT_SellOutCollect__c>();
        /*if (this.client.ReferenceAccount__c == null) {
            coletas = this.getSellOutHeadersQueryNoClient(this.month, this.year);
        } else {
            coletas = this.getSellOutHeadersQuery(this.month, this.client.ReferenceAccount__c, this.year);
        }*/

        coletas = this.getSellOutHeadersQuery(this.month, this.client.ReferenceAccount__c, this.year, this.dummyOwner.Area_Manager__c);
 		
 		this.fillingColeta = new LAT_SellOutCollect__c();
        for (LAT_SellOutCollect__c soc: coletas) {
            result.add(new SellOutCollectHeader(soc, this.enableDeleting));
            if (soc.Status__c == 'Filling' || soc.Status__c == 'Preenchimento') {
                this.fillingColeta = soc;
            }
        }
        
        return result;
    }

    private void getFillingColeta() {
        Date filterDate = Date.newInstance(Integer.valueOf(this.year), Integer.valueOf(this.month), 1);
        List<SellOutCollectHeader> result = new List<SellOutCollectHeader>();

        List<LAT_SellOutCollect__c> coletas = [SELECT id, Name, ReferenceAccount__c, toLabel(Status__c), ReferencedMonth__c,
                                                    Owner.Name, OwnerId , CreatedDate, ReferenceAccount__r.Name
                                                FROM LAT_SellOutCollect__c
                                                WHERE ReferencedMonth__c =: filterDate
                                                      AND ReferenceAccount__c =: this.client.ReferenceAccount__c
                                                      AND (Status__c = 'Filling' OR Status__c = 'Preenchimento')
                                                      AND recordType.developerName = 'LAT_SellOut'];


        this.fillingColeta = new LAT_SellOutCollect__c();
        for (LAT_SellOutCollect__c soc: coletas) {
            if (soc.Status__c == 'Filling' || soc.Status__c == 'Preenchimento') {
                this.fillingColeta = soc;
            }
        }

    }

    public String buildQuery(Date filterDate, String clientId, String ownerId) {
        String Base = 'SELECT id, Name, ReferenceAccount__c, toLabel(Status__c), ReferencedMonth__c,' 
                             + ' Owner.Name, OwnerId , CreatedDate, ReferenceAccount__r.Name'
                        + ' FROM LAT_SellOutCollect__c'
                        + ' WHERE ReferencedMonth__c =: filterDate AND recordType.developerName = \'LAT_SellOut\'';
        
        if (clientId != null && clientId != '') {
            Base += ' AND ReferenceAccount__c =: clientId';
        }
        if (ownerId != null && ownerId != '') {
            Base += ' AND OwnerId =: ownerId';
        }

        Base += ' ORDER BY name DESC, createdDate';

        return Base;
                        
    }

    // Returns the string query to get the headers objects
    public List<LAT_SellOutCollect__c> getSellOutHeadersQuery(String month, String clientId, String year, String ownerId) {
        Date filterDate = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), 1);
        return Database.query(this.buildQuery(filterDate, clientId, ownerId));

                /*[SELECT id, Name, ReferenceAccount__c, toLabel(Status__c), ReferencedMonth__c,
                       Owner.Name, OwnerId , CreatedDate, ReferenceAccount__r.Name
                FROM LAT_SellOutCollect__c
                WHERE ReferenceAccount__c =: clientId  
                      AND ReferencedMonth__c =: filterDate
                        ORDER BY name DESC, createdDate];*/
    }

    // Returns the string query to get all the headers objects 
    /*public List<LAT_SellOutCollect__c> getSellOutHeadersQueryNoClient(String month, String year) {
        Date filterDate = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), 1);
        return [SELECT id, Name, ReferenceAccount__c, toLabel(Status__c), ReferencedMonth__c,
                       Owner.Name, OwnerId , CreatedDate, ReferenceAccount__r.Name
                FROM LAT_SellOutCollect__c
                WHERE ReferencedMonth__c =: filterDate
                        ORDER BY name DESC, createdDate];
    }*/

    public void doDelete() {
        String obid = Apexpages.currentPage().getParameters().get('obid');
        Integer iter = 0;
        for (SellOutCollectHeader sch: this.headerList) {
            if (obid == sch.objid) {
                delete sch.soc;
                this.headerList.remove(iter);
                break;
            }
            iter++;
        }
        
    }

    public PageReference doColeta() {
        if (this.client.ReferenceAccount__c != null && this.year != null && this.year != '') {
            //this.headerList = getHeaders(); 
            //if (headerList.size() > 0){
            getFillingColeta();
            system.debug('----->' + this.client.ReferenceAccount__c);
            if (this.fillingColeta.id != null){
            	return new PageReference('/apex/LAT_BR_VFP29_SellOutCollectFilling?colId=' + this.fillingColeta.id);
            } else {
            	return new PageReference('/apex/LAT_BR_VFP29_SellOutCollectFilling?action=New&month=' + this.month + '&year=' + this.year + '&refAId=' + this.client.ReferenceAccount__c); 
            }
        } else {

            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Favor informar o Cliente, Mês e Ano para Coletar.'); 
            ApexPages.addMessage(errorMsg);
            
            return null;
        }
    }

    // This inner class will be used to display Header object information
    public class SellOutCollectHeader {
        public LAT_SellOutCollect__c soc {get; set;}
        public String name {get; set;}
        public String objid {get; set;}
        public String year {get; set;}
        public String month {get; set;}
        public String status {get; set;}
        public String owner {get; set;}
        public Boolean enableEditing {get; set;}
        public Boolean enableDeleting {get; set;}
        public DateTime createdDate {get;set;}
        public String clientName {get; set;}
        
        // It receives the header object and works with the data 
        public SellOutCollectHeader (LAT_SellOutCollect__c soc, Boolean enableDeleting){
            this.soc = soc;
            this.name = soc.Name;
            this.objid = soc.id;
            this.year = soc.ReferencedMonth__c != null ? 
                            String.valueOf(soc.ReferencedMonth__c.year()) : currentYear;
            
            Integer monthNumber = soc.ReferencedMonth__c != null ? 
                                    soc.ReferencedMonth__c.month() : Integer.valueOf(currentMonth);
            this.month = monthList.get(monthNumber);
            this.status = soc.Status__c;
            this.owner = soc.Owner.Name;
            this.clientName = soc.ReferenceAccount__r.Name;
            if (soc.Status__c == 'Filling' || soc.Status__c == 'Preenchimento') {
                this.enableEditing = true;
            }

            //DateTime theDate = date.newinstance(soc.createdDate.year(), soc.createdDate.month(), soc.createdDate.day());
            //theDate.format('DD-MM-YYYY');
            this.createdDate = soc.createdDate;
            this.enableDeleting = enableDeleting;
        }
    }
}