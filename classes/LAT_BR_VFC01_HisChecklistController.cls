public with sharing class LAT_BR_VFC01_HisChecklistController{
    
    public list<Checklist_de_visita__c> checklistsCLiente {get;set;}
    public Boolean prevDisable {get;set;}
    public Boolean nextDisable {get;set;}
    public Integer pageSize {get;set;}
    
    private Visitas__c visita;
    private PagerGeneral pager;
    
    public LAT_BR_VFC01_HisChecklistController(){
        prevDisable = false;
        nextDisable = false;
        pageSize = 50;
        checklistsCLiente = new list<Checklist_de_visita__c>();
        
        Id visitaId = ApexPages.currentPage().getparameters().get('idVisita');
        
        if(visitaId != null){
            visita = [SELECT Id, Conta__c FROM Visitas__c WHERE Id =: visitaId];
            generatePager();
            loadList();
        }
       
    }

    public void doDelete(){
        // Método que me sirve para borrar un checklist de visita
        String idABorrar = ApexPages.currentPage().getParameters().get('idABorrar');
        
        try {
            checklist_de_visita__c checklistABorrar = [SELECT id FROM checklist_de_visita__c  WHERE id =: idABorrar];
            delete checklistABorrar;
        }catch(exception e){return;}
                       
        generatePager();
        loadList();
    }
    
    public pageReference doEdit(){
        // Método que sirve para editar un checklist de visita
        // Según el id que me pasan por parametro se redirecciona al edit de ese registro
        String idAEditar = ApexPages.currentPage().getParameters().get('idAEditar');
        String retUrl = '/apex/LAT_BR_VFC01_HisChecklist/idVisita='+visita.Id;
        return new pagereference ('/'+idAEditar+'/e?retUrl='+'/apex/LAT_BR_VFC01_HisChecklist/idVisita='+visita.Id);
    }
    
    public pageReference doVolver(){
        // Método que sirve para volver a la visita
        return new pagereference ('/'+visita.Id);
        
    }
    
    private void generatePager(){
        String query = 'SELECT id, name, visita__r.conta__c, CreatedDate, visita__c, visita__r.Status__c FROM checklist_de_visita__c WHERE visita__r.conta__c = \''+visita.Conta__c+'\' ORDER BY CreatedDate';
        pager = new PagerGeneral(Database.getQueryLocator(query) ,pageSize);
    }
     
    private void loadList(){
        if(pager!=null){
            checklistsCLiente = (List<checklist_de_visita__c>)pager.getRecords();
            prevDisable = false;
            if(!pager.hasPrevious){prevDisable = true;}
            nextDisable = false;
            if(!pager.hasNext){nextDisable = true;}
        }
    }
     
    public void doPrevious() {
        pager.previous();
        loadList();
    }
     
    public void doNext(){
        pager.next();
        loadList();
    }   
   
}