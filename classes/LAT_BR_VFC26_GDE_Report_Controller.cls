public with sharing class LAT_BR_VFC26_GDE_Report_Controller {
	//public Date visitMonth {get; set;}
	//public User owner {get; set;}
	//public String regionaAccount {get; set;}

	
	private Map<Integer, String> monthOfYear = new Map<Integer, String>{1 => 'Janeiro', 2 => 'Fevereiro',3 => 'Março',
															4 => 'Abril',5 => 'Maio',6 => 'Junho',7 => 'Julho',
															8 => 'Agosto',9 => 'Setembro',10 => 'Outubro',11 => 'Novembro',
															12 => 'Dezembro'};

	public Account dummyAccountFilters {get; set;}
	public Planejamento__c dummyPlanFilters {get; set;}

	public Integer visibilidadeRealizado {get; set;}
	public Integer visibilidadeSupera {get; set;}
	public Integer visibilidadeNaoRealizado {get; set;}
	public Integer persuasaoRealizado {get; set;}
	public Integer persuasaoSupera {get; set;}
	public Integer persuasaoNaoRealizado {get; set;}
	public Integer cardapioRealizado {get; set;}
	public Integer cardapioSupera {get; set;}
	public Integer cardapioNaoRealizado {get; set;}
	public Integer embaixadaRealizado {get; set;}
	public Integer embaixadaSuperado {get; set;}
	public Integer embaixadaNaoRealizado {get; set;}

	public transient Boolean ran {get;set;}
	public transient String reportName {get;set;}
	public Boolean hasAccess {get;Set;}

	public LAT_BR_VFC26_GDE_Report_Controller() {
		//visitMonth = Date.today();

		//Check de seguridad del reporte por medio del objeto LAT_CRP_Custom_Report__c  
        ran = false;
        hasAccess = false;
        string idFromReport = ApexPages.currentPage().getParameters().get('IdRep');
        
        LAT_CRP_Custom_Report__c crp;
        try{crp = [SELECT Id, LAT_VisualForceName__c, LAT_ReportName__c FROM LAT_CRP_Custom_Report__c WHERE id =: idFromReport];}catch(Exception e){}
        if(crp != null && crp.LAT_VisualForceName__c == 'LAT_BR_VFP26_GabaritoOnTradeReport'){
            hasAccess = true;
            reportName = crp.LAT_ReportName__c;
        }else{
            return;
        }

		this.dummyAccountFilters = new Account();
		this.dummyPlanFilters = new Planejamento__c(Ano_de_Referencia__c = String.valueOf(Date.today().year()),
													M_s_de_Ref_rencia__c = monthOfYear.get(Date.today().month()));

		
		//owner = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		this.calculateReport();		
	}

	public PageReference calculateReport() {

		visibilidadeRealizado = 0;
		visibilidadeSupera = 0;
		visibilidadeNaoRealizado = 0;
		persuasaoRealizado = 0;
		persuasaoSupera = 0;
		persuasaoNaoRealizado = 0;
		cardapioRealizado = 0;
		cardapioSupera = 0;
		cardapioNaoRealizado = 0;
		embaixadaRealizado = 0;
		embaixadaSuperado = 0;
		embaixadaNaoRealizado = 0;

		/*List<AggregateResult> lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_Visibility__c = 2];*/
		System.debug('aaaaaaaaaaaaaa  ' + dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c);
		List<AggregateResult> lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_Visibility__c = 3', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));
		System.debug('bbbbbbbbbbbbbb  ' + lstRes);
		
		visibilidadeRealizado = Integer.valueOf(lstRes[0].get('cant'));

		/*lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_Visibility__c > 2];*/
		lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_Visibility__c > 3', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));
		visibilidadeSupera = Integer.valueOf(lstRes[0].get('cant'));

		/*lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_Visibility__c < 2];*/
		lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_Visibility__c < 3', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));
		visibilidadeNaoRealizado = Integer.valueOf(lstRes[0].get('cant'));

		/*lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_PersuationRating__c = 1];*/
		lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_PersuationRating__c = 1', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));
		persuasaoRealizado = Integer.valueOf(lstRes[0].get('cant'));

		/*lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_PersuationRating__c > 1];*/
		lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_PersuationRating__c > 1', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));
		persuasaoSupera = Integer.valueOf(lstRes[0].get('cant'));

		/*lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_PersuationRating__c < 1];*/
		lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_PersuationRating__c < 1', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));		
		persuasaoNaoRealizado = Integer.valueOf(lstRes[0].get('cant'));

		/*lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_CardapioRating__c = 1];*/
		lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_CardapioRating__c = 1', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));
		cardapioRealizado = Integer.valueOf(lstRes[0].get('cant'));

		/*lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_CardapioRating__c = 0];*/
		lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_CardapioRating__c = 0', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));
		cardapioNaoRealizado = Integer.valueOf(lstRes[0].get('cant'));

		/*lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_Embassy__c = 0];*/
		lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_Embassy__c = 0', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));
		embaixadaNaoRealizado = Integer.valueOf(lstRes[0].get('cant'));

		/*lstRes = [SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE 
										Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = :dummyPlanFilters.M_s_de_Ref_rencia__c 
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = :dummyPlanFilters.Ano_de_Referencia__c
										AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = :dummyPlanFilters.OwnerId  
										AND LAT_BR_GDE_Embassy__c = 1];*/
		lstRes = Database.Query(this.buildQuery('LAT_BR_GDE_Embassy__c = 1', dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c));
		embaixadaRealizado = Integer.valueOf(lstRes[0].get('cant'));

		return null;
	}

	String rtOffBRGab = Global_RecordTypeCache.getRtId('Gabarito_de_Execucao__c' + 'LAT_BR_GDE_On_Trade');
	public string buildQuery(String filterField, String regional) {
		String baseQuery = 'SELECT COUNT(Id)cant FROM Gabarito_de_Execucao__c WHERE'+
								' RecordTypeId = \'' + rtOffBRGab + '\'' +
								' AND Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklistGE__c = true' +
								' AND Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = \'' + dummyPlanFilters.M_s_de_Ref_rencia__c + '\'' +
								' AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = \'' + dummyPlanFilters.Ano_de_Referencia__c + '\'';

		system.debug('RM ---------> ' + dummyAccountFilters.Regional_Manager__c);

		if (dummyAccountFilters.Regional_Manager__c != null) {
			baseQuery += ' AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = \'' + dummyAccountFilters.Regional_Manager__c + '\'';
		}
		if (regional != null && regional != '') {
			baseQuery += ' AND Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c = \'' + regional + '\'';
		}
		if (filterField != null && filterField != '') {
			baseQuery += ' AND ' + filterField;
		}

		system.debug('BQ ---------> ' + baseQuery);
		
		return baseQuery;
	}
	
}