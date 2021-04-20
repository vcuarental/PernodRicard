public with sharing class LAT_MX_OpportunityAttachmentUpload {
	
	public Attachment archivo       {get {
                                        if(archivo== null)
                                          archivo= new Attachment();
                                        return archivo;
                                     } set;}
    public String nombreArchivo    {get; set;}
	public LAT_Opportunity__c dummyOpp {get; set;}
    public String successMessage    {get; set;}
    public String errorMessage      {get; set;}
    public Map<ID, LAT_Opportunity__c> opportunitiesToUpload  {get; set;}
    public List<OppWrapper> opportunitiesFound  {get; set;}
    public Boolean selectAll		{get; set;} 
    public Id 	idPedido			{get; set;}


	public LAT_MX_OpportunityAttachmentUpload() {
		this.dummyOpp = new LAT_Opportunity__c();
		this.selectAll = false;
		this.opportunitiesToUpload = new Map<Id, LAT_Opportunity__c>();
		this.opportunitiesFound 		= new List<OppWrapper>();
		String msg = ApexPages.currentPage().getParameters().get('successMessage');
		if(msg != null) {
			this.errorMessage = msg;
		} else{
			this.errorMessage = '';
		}
		
	}

	public PageReference upload(){
		System.debug('%%%%%% entramos en upload, this.archivo : ' + this.archivo);
		System.debug('%%%%%% entramos en upload, this.dummyOpp : ' + this.dummyOpp);
		if(this.archivo == null) return null;
		List<Attachment> toInsert = new List<Attachment>();
		for(LAT_Opportunity__c op : this.opportunitiesToUpload.values()) {
			Attachment nuevo = new Attachment();
			nuevo.parentId = op.Id;
			nuevo.Description = this.dummyOpp.LAT_DSMessage1__c;
			nuevo.Body		= archivo.Body;
			nuevo.Name		= archivo.Name;

			toInsert.add(nuevo);
		}
		this.archivo = null;
		if(toInsert.size() > 0){
			insert toInsert;
		}
		this.opportunitiesToUpload = new Map<Id, LAT_Opportunity__c>();
		this.opportunitiesFound 		= new List<OppWrapper>();
		this.successMessage = 'Se anexó correctamente el Archivo en ' + toInsert.size() + ' Pedidos.';
		this.dummyOpp = new LAT_Opportunity__c();
		return new pagereference('/apex/LAT_MX_OpportunityAttachmentUpload?successMessage='+this.successMessage);
	}

	public static PageReference salir(){
		try{
			PageReference pg =new pagereference('/home/home.jsp');
			pg.setRedirect(true);
			return pg;
		} catch(Exception e) {
			PageReference pg =new pagereference('/home/home.jsp');
			pg.setRedirect(true);
			return pg;
		}
		
	}
	public PageReference quitarPedidoDeSeleccion(){
		System.debug('%%%%%% entramos en quitarPedidoDeSeleccion, idPedido : ' + idPedido);
		this.opportunitiesToUpload.remove(idPedido);
		buscarOpportunities();
		return null;
	}

	public PageReference agregarOpportunities(){
		List<OppWrapper> remainingWraps = new List<OppWrapper>();
		for(OppWrapper wrap : this.opportunitiesFound) {
			if(wrap.isSelected) {
				this.opportunitiesToUpload.put(wrap.opp.Id, wrap.opp);
			} else {
				remainingWraps.add(wrap);
			}
		}
		this.opportunitiesFound = remainingWraps;

		return null;
	}

	public PageReference buscarOpportunities(){
		System.debug('%%%%%% entramos en buscarOpportunities');
		System.debug('%%%%%% this.dummyOpp.LAT_Account__c : ' + this.dummyOpp.LAT_Account__c);
		this.opportunitiesFound = new List<OppWrapper>();
		if(this.dummyOpp.LAT_Account__c == null) {
			this.errorMessage = 'Debe seleccionar un Cliente para buscar los pedidos.';
			return null;
		}
		List<LAT_Opportunity__c> foundOpps = [SELECT Id, Name, LAT_CloseDate__c, LAT_Account__r.Name, LAT_NROrderJDE__c FROM 
												LAT_Opportunity__c WHERE LAT_Account__c = :this.dummyOpp.LAT_Account__c AND Createddate >= LAST_N_MONTHS:4 
												AND Id NOT IN :opportunitiesToUpload.KeySet() ORDER BY LAT_CloseDate__c DESC];
		System.debug('%%%%%% foundOpps : ' + foundOpps);
		for (LAT_Opportunity__c opp : foundOpps) {
			this.opportunitiesFound.add(new OppWrapper(opp));

		}	
		System.debug('%%%%%% this.opportunitiesFound : ' + this.opportunitiesFound);
		return null;
	}

	public class OppWrapper {
		public LAT_Opportunity__c opp {get; set;}
		public Boolean 		isSelected {get; set;}

		public OppWrapper(LAT_Opportunity__c oppParam) {
			opp = oppParam;
		}

	}
}