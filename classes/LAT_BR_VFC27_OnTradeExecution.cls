public with sharing class LAT_BR_VFC27_OnTradeExecution {

	private Map<Integer, String> monthOfYear = new Map<Integer, String>{1 => 'Janeiro', 2 => 'Fevereiro',3 => 'Março',
															4 => 'Abril',5 => 'Maio',6 => 'Junho',7 => 'Julho',
															8 => 'Agosto',9 => 'Setembro',10 => 'Outubro',11 => 'Novembro',
															12 => 'Dezembro'};
	String rtOffBRGab = Global_RecordTypeCache.getRtId('Gabarito_de_Execucao__c' + 'LAT_BR_GDE_On_Trade');
														
	public Account dummyAccountFilters {get; set;}
	public Planejamento__c dummyPlanFilters {get; set;}
	
	public transient Boolean ran {get;set;}
	public transient String reportName {get;set;}
	
    public Boolean ExportToExcel {get;set;}
	public Boolean hasAccess {get;set;}

	public List<Gabarito_de_Execucao__c> geList {get; set;}

	public LAT_BR_VFC27_OnTradeExecution() {
		ran = false;
        hasAccess = false;
        this.ExportToExcel = false;
        string idFromReport = ApexPages.currentPage().getParameters().get('IdRep');
        
        LAT_CRP_Custom_Report__c crp;
        try{crp = [SELECT Id, LAT_VisualForceName__c, LAT_ReportName__c FROM LAT_CRP_Custom_Report__c WHERE id =: idFromReport];}catch(Exception e){}
        if(crp != null && crp.LAT_VisualForceName__c == 'LAT_BR_VFP27_OnTradeExecution'){
            hasAccess = true;
            reportName = crp.LAT_ReportName__c;
        }else{
            return;
        }

		this.dummyAccountFilters = new Account(OwnerId = UserInfo.getUserId());
		this.dummyPlanFilters = new Planejamento__c(OwnerId = UserInfo.getUserId(), 
													Ano_de_Referencia__c = String.valueOf(Date.today().year()),
													M_s_de_Ref_rencia__c = monthOfYear.get(Date.today().month()));

		this.calculateReport();		
	}

	public PageReference calculateReport() {
		this.geList = this.getRecords(dummyAccountFilters.LAT_BR_RegionalClientOnPremise__c);
		return null;
	}

	public List<Gabarito_de_Execucao__c> getRecords(string regional) {
		String baseQuery = 'SELECT id, Name, Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c, Checklist_de_Visita__r.Visita__r.Conta__r.Owner.Name, ' +
								' Checklist_de_Visita__r.Visita__r.Conta__r.Revenue_City__r.Name,  Checklist_de_Visita__r.Visita__r.Conta__r.Revenue_UF__c,' + 
								' Checklist_de_Visita__r.Visita__r.Conta__r.Name, Checklist_de_Visita__r.Visita__r.Conta__r.Subtype__c, Checklist_de_Visita__r.Visita__r.Conta__r.Segmentation_Type_on_trade__c,' + 
								' Checklist_de_Visita__r.Visita__r.Conta__r.Rating, Checklist_de_Visita__r.Visita__r.Name, Checklist_de_Visita__r.Visita__c,' + 
								' Checklist_de_Visita__r.Visita__r.Conta__r.Sub_Channel_Rating__r.Name, Checklist_de_Visita__r.Visita__r.Conta__r.Type,' +
								' LAT_BR_GDE_General_Enviroment__c, LAT_BR_GDE_Backbar__c, LAT_BR_GDE_Stage_DJBooth__c, LAT_BR_GDE_Table__c, LAT_BR_GDE_Brigade__c,' +
								' LAT_BR_GDE_Cabin__c, LAT_BR_GDE_Brigade_Persuasion__c, LAT_BR_GDE_Action__c, LAT_BR_GDE_Products_Listed_on_Menues__c,' +
								' LAT_BR_GDE_Not_Listed_Brands__c, LAT_BR_GDE_Visibility__c, LAT_BR_GDE_Persuation__c, LAT_BR_GDE_Menu__c, LAT_BR_GDE_Embassy__c,' +
								' Checklist_de_Visita__r.Visita__r.Conta__r.Rating_segmentation_targert_market__c' +
							' FROM Gabarito_de_Execucao__c WHERE' +
								' RecordTypeId = \'' + rtOffBRGab + '\'' +
								' AND Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklistGE__c = true' +
								' AND Checklist_de_Visita__r.Visita__r.Planejamento__r.M_s_de_Ref_rencia__c = \'' + dummyPlanFilters.M_s_de_Ref_rencia__c + '\'' +
								' AND Checklist_de_Visita__r.Visita__r.Planejamento__r.Ano_de_Referencia__c = \'' + dummyPlanFilters.Ano_de_Referencia__c + '\'';
								

		if (dummyAccountFilters.Regional_Manager__c != null) {
			baseQuery += ' AND Checklist_de_Visita__r.Visita__r.Planejamento__r.OwnerId = \'' + dummyAccountFilters.Regional_Manager__c + '\'';
		}
		if (regional != null && regional != '') {
			baseQuery += ' AND Checklist_de_Visita__r.Visita__r.Conta__r.LAT_BR_RegionalClientOnPremise__c = \'' + regional + '\'';
		}

		return Database.query(baseQuery);
	}


	public PageReference exportToExcel() {
		this.ExportToExcel = true;
		return null;
	}
}