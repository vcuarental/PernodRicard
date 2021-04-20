/********************************************************************************
* Pending Approvals Report for BR controller
*
* NAME: LAT_BR_VFC16_PendingApprovalReportCont.cls
* AUTHOR: Mariano Boezio                           DATE: 17/02/2015
********************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 03/11/2016
*
********************************************************************************/
public with sharing class LAT_BR_VFC16_PendingApprovalReportCont {
	

	public LAT_reportFilters LAT_filters 		{get; set;}
	public reportFilters filters				{get; set;}
	public List<approvalWrapper> wrapperList 	{get; set;}
	public Boolean hasAccess 					{get; set;}
	private String baseQueryStart = 'SELECT Status, TargetObjectId, TargetObject.Name, ProcessDefinitionId, '
			 						+ 'CreatedBy.Country, CreatedBy.Name, CreatedBy.Regional_de_vendas__c, tolabel(TargetObject.type), ';
	private String baseRelatedQuery = '(SELECT ActorId, CreatedDate, Actor.Name '
										+ 'FROM Workitems {0} ORDER BY CreatedDate DESC LIMIT 49000), '
										+ '(SELECT ActorId, CreatedDate, Actor.Name '
										+ 'FROM Steps ORDER BY CreatedDate ASC LIMIT 49000) ';
	private String baseQueryEnd	= 'FROM ProcessInstance WHERE (Status = \'Pending\' OR Status = \'Submitted\') ';

	public LAT_BR_VFC16_PendingApprovalReportCont() {
		hasAccess = false;
        string idFromReport = ApexPages.currentPage().getParameters().get('IdRep');
        
        LAT_CRP_Custom_Report__c crp;
        try{crp = [SELECT Id, LAT_VisualForceName__c, LAT_ReportName__c FROM LAT_CRP_Custom_Report__c WHERE id =: idFromReport];}catch(Exception e){}
        //MIGRATED 25/11/2016 
        if(!Utils.wasMigrationDone('1')) { 
            if(crp != null && crp.LAT_VisualForceName__c == 'LAT_BR_VFP22_PendingApprovalReport'){
                hasAccess = true;
            }else{
                return;
            }
        }else{
            if(crp != null && crp.LAT_VisualForceName__c == 'LAT_BR2_VFP22_PendingApprovalReport'){
                hasAccess = true;
            }else{
                return;
            }
        }
        if(!Utils.wasMigrationDone('1')){
			this.filters = new reportFilters();
			this.wrapperList = this.getWrapperList(this.filters);
		}else{
			this.LAT_filters = new LAT_reportFilters();
			this.wrapperList = this.getWrapperList(this.LAT_filters);
		}
	}

	//MIGRATED 03/11/2016 
	public void applyFilters() {
		if(!Utils.wasMigrationDone('1')){
			this.wrapperList = this.getWrapperList(this.filters);
		} 
		else {
			this.wrapperList = this.getWrapperList(this.LAT_filters);
		}
	}

	private List<approvalWrapper> getWrapperList(reportFilters rFilters){
		List<approvalWrapper> wpList = new List<approvalWrapper>();
        System.debug('%%%%%%%% buildQuery(rFilters)  : '+buildQuery(rFilters));
		List<ProcessInstance> piList = Database.query(buildQuery(rFilters));
		List<ProcessInstance> filteredPiList = new List<ProcessInstance>();
		
		Set<String> TOIds = new Set<String>();
		for (ProcessInstance pi: piList) {
			// Can't filter query by country due to Illegal filter on ProcessInstance exception
			if (pi.CreatedBy.Country == 'BR' || pi.CreatedBy.Country == 'Brasil') {
				TOIds.add(pi.TargetObjectId);
				filteredPiList.add(pi);
			}
		}
		Map<id, Account> accMap = new Map<id, Account>([SELECT id, Rating, Name FROM Account WHERE id IN: TOIds]);
		Map<id, LAT_BR_ClientChannelSegmentation__c> segMap = new Map<id, LAT_BR_ClientChannelSegmentation__c>([SELECT id, LAT_BR_Client__c, LAT_BR_Client__r.Rating, LAT_BR_Client__r.Name, LAT_BR_Justificativa__c FROM LAT_BR_ClientChannelSegmentation__c WHERE id IN: TOIds]);
		Map<id, Case> caseMap = new Map<id, Case>([SELECT id, Account.Rating, Account.Name, AccountId FROM Case WHERE id IN: TOIds]);
		Map<id, LAT_Contract__c> contratoMap = new Map<id, LAT_Contract__c>([SELECT id, Account__r.Rating, Account__r.Name, Account__c FROM LAT_Contract__c WHERE id IN: TOIds]);
		Map<id, Analise_de_credito__c> adcMap = new Map<id, Analise_de_credito__c>([SELECT id, Conta__r.Rating, Conta__r.Name, Conta__c FROM Analise_de_credito__c WHERE id IN: TOIds]);
		Map<id, Opportunity> oppMap = new Map<id, Opportunity>([SELECT id, Account.Rating, Account.Name, AccountId FROM Opportunity WHERE id IN: TOIds]);


		for (ProcessInstance pi: filteredPiList) {
			if (!pi.Workitems.isEmpty()) {
				Account Client = accMap.get(pi.TargetObjectId);
				LAT_BR_ClientChannelSegmentation__c Seg = segMap.get(pi.TargetObjectId);
				Case cas = caseMap.get(pi.TargetObjectId);
				LAT_Contract__c contrato = contratoMap.get(pi.TargetObjectId);
				Analise_de_credito__c adc = adcMap.get(pi.TargetObjectId);
				Opportunity opp = oppMap.get(pi.TargetObjectId);

				String currentApprover = pi.Workitems.get(0).Actor.Name;
				String clientName = this.getClientName(Client, Seg, cas, contrato, adc, opp);
				String clientRating = this.getClientRating(Client, Seg, cas, contrato, adc, opp);
				String clientId = this.getClientId(Client, Seg, cas, contrato, adc, opp);
				String justificationSeg = Seg != null ? Seg.LAT_BR_Justificativa__c : '-';
				String lastApprover = pi.Steps.size() > 1 ? pi.Steps.get(1).Actor.Name : '-';
				DateTime receivingDate = pi.Steps.get(0).createdDate;

				wpList.add(new approvalWrapper(currentApprover, clientName, clientRating, pi.TargetObject.Name,
												 pi.TargetObject.Type, lastApprover, pi.CreatedBy.Name, pi.CreatedBy.Regional_de_vendas__c,
												 receivingDate, justificationSeg, pi.TargetObjectId, clientId));
			}
		}

		return wpList;
	}

	//MIGRATED 03/11/2016 
	private List<approvalWrapper> getWrapperList(LAT_reportFilters rFilters){
		List<approvalWrapper> wpList = new List<approvalWrapper>();
		List<ProcessInstance> piList = Database.query(buildQuery(rFilters));
		List<ProcessInstance> filteredPiList = new List<ProcessInstance>();
		
		Set<String> TOIds = new Set<String>();
		for (ProcessInstance pi: piList) {
			// Can't filter query by country due to Illegal filter on ProcessInstance exception
			if (pi.CreatedBy.Country == 'BR' || pi.CreatedBy.Country == 'Brasil') {
				TOIds.add(pi.TargetObjectId);
				filteredPiList.add(pi);
			}
		}

		Map<id, Account> accMap = new Map<id, Account>([SELECT id, Rating, Name FROM Account WHERE id IN: TOIds]);
		Map<id, LAT_BR_ClientChannelSegmentation__c> segMap = new Map<id, LAT_BR_ClientChannelSegmentation__c>([SELECT id, LAT_BR_Client__c, LAT_BR_Client__r.Rating, LAT_BR_Client__r.Name, LAT_BR_Justificativa__c FROM LAT_BR_ClientChannelSegmentation__c WHERE id IN: TOIds]);
		Map<id, LAT_Case__c> caseMap = new Map<id, LAT_Case__c>([SELECT id, LAT_Account__r.Rating, LAT_Account__r.Name, LAT_Account__c FROM LAT_Case__c WHERE id IN: TOIds]);
		Map<id, LAT_Contract__c> contratoMap = new Map<id, LAT_Contract__c>([SELECT id, Account__r.Rating, Account__r.Name, Account__c FROM LAT_Contract__c WHERE id IN: TOIds]);
		Map<id, Analise_de_credito__c> adcMap = new Map<id, Analise_de_credito__c>([SELECT id, Conta__r.Rating, Conta__r.Name, Conta__c FROM Analise_de_credito__c WHERE id IN: TOIds]);
		Map<id, LAT_Opportunity__c> oppMap = new Map<id, LAT_Opportunity__c>([SELECT id, LAT_Account__r.Rating, LAT_Account__r.Name, LAT_Account__c FROM LAT_Opportunity__c WHERE id IN: TOIds]);


		for (ProcessInstance pi: filteredPiList) {
			if (!pi.Workitems.isEmpty()) {
				Account Client = accMap.get(pi.TargetObjectId);
				LAT_BR_ClientChannelSegmentation__c Seg = segMap.get(pi.TargetObjectId);
				LAT_Case__c cas = caseMap.get(pi.TargetObjectId);
				LAT_Contract__c contrato = contratoMap.get(pi.TargetObjectId);
				Analise_de_credito__c adc = adcMap.get(pi.TargetObjectId);
				LAT_Opportunity__c opp = oppMap.get(pi.TargetObjectId);

				String currentApprover = pi.Workitems.get(0).Actor.Name;
				String clientName = this.getClientName(Client, Seg, cas, contrato, adc, opp);
				String clientRating = this.getClientRating(Client, Seg, cas, contrato, adc, opp);
				String clientId = this.getClientId(Client, Seg, cas, contrato, adc, opp);
				String justificationSeg = Seg != null ? Seg.LAT_BR_Justificativa__c : '-';
				String lastApprover = pi.Steps.size() > 1 ? pi.Steps.get(1).Actor.Name : '-';
				DateTime receivingDate = pi.Steps.get(0).createdDate;

				wpList.add(new approvalWrapper(currentApprover, clientName, clientRating, pi.TargetObject.Name,
												 pi.TargetObject.Type, lastApprover, pi.CreatedBy.Name, pi.CreatedBy.Regional_de_vendas__c,
												 receivingDate, justificationSeg, pi.TargetObjectId, clientId));
			}
		}
		
		return wpList;
	}

	public String getClientName(Account Client, LAT_BR_ClientChannelSegmentation__c Seg, Case cas, LAT_Contract__c contrato, Analise_de_credito__c adc, Opportunity opp) {
		if (Client != null) {
			return Client.Name;
		} else if (Seg != null) {
			return Seg.LAT_BR_Client__r.Name;
		} else if (contrato != null) {
			return contrato.Account__r.Name;
		} else if (cas != null && cas.AccountId!=null) {
			return cas.Account.Name;
		} else if (adc != null) {
			return adc.Conta__r.Name;	
		} else if (opp != null && opp.AccountId != null) {
			return opp.Account.Name;	
		} else {
			return '-';
		}

	}
    //MIGRATED 03/11/2016 
	public String getClientName(Account Client, LAT_BR_ClientChannelSegmentation__c Seg, LAT_Case__c cas, LAT_Contract__c contrato, Analise_de_credito__c adc, LAT_Opportunity__c opp) {
		if (Client != null) {
			return Client.Name;
		} else if (Seg != null) {
			return Seg.LAT_BR_Client__r.Name;
		} else if (contrato != null) {
			return contrato.Account__r.Name;
		} else if (cas != null && cas.LAT_Account__c!=null) {
			return cas.LAT_Account__r.Name;
		} else if (adc != null) {
			return adc.Conta__r.Name;	
		} else if (opp != null && opp.LAT_Account__c != null) {
			return opp.LAT_Account__r.Name;	
		} else {
			return '-';
		}

	}

	public String getClientRating(Account Client, LAT_BR_ClientChannelSegmentation__c Seg, Case cas, LAT_Contract__c contrato, Analise_de_credito__c adc, Opportunity opp) {
		if (Client != null) {
			return Client.Rating;
		} else if (Seg != null) {
			return Seg.LAT_BR_Client__r.Rating;
		} else if (contrato != null) {
			return contrato.Account__r.Rating;
		} else if (cas != null && cas.AccountId!=null) {
			return cas.Account.Rating;
		} else if (adc != null) {
			return adc.Conta__r.Rating;	
		} else if (opp != null && opp.AccountId != null) {
			return opp.Account.Rating;	
		} else {
			return '-';
		}

	}
    //MIGRATED 03/11/2016 
	public String getClientRating(Account Client, LAT_BR_ClientChannelSegmentation__c Seg, LAT_Case__c cas, LAT_Contract__c contrato, Analise_de_credito__c adc, LAT_Opportunity__c opp) {
		if (Client != null) {
			return Client.Rating;
		} else if (Seg != null) {
			return Seg.LAT_BR_Client__r.Rating;
		} else if (contrato != null) {
			return contrato.Account__r.Rating;
		} else if (cas != null && cas.LAT_Account__c!=null) {
			return cas.LAT_Account__r.Rating;
		} else if (adc != null) {
			return adc.Conta__r.Rating;	
		} else if (opp != null && opp.LAT_Account__c != null) {
			return opp.LAT_Account__r.Rating;	
		} else {
			return '-';
		}

	}

	public String getClientId(Account Client, LAT_BR_ClientChannelSegmentation__c Seg, Case cas, LAT_Contract__c contrato, Analise_de_credito__c adc, Opportunity opp) {
		if (Client != null) {
			return Client.id;
		} else if (Seg != null) {
			return Seg.LAT_BR_Client__c;
		} else if (contrato != null) {
			return contrato.Account__c;
		} else if (cas != null && cas.AccountId !=null) {
			return cas.AccountId;
		} else if (adc != null) {
			return adc.Conta__c;	
		} else if (opp != null && opp.AccountId != null) {
			return opp.AccountId;	
		} else {
			return '-';
		}

	}
    //MIGRATED 03/11/2016 
	public String getClientId(Account Client, LAT_BR_ClientChannelSegmentation__c Seg, LAT_Case__c cas, LAT_Contract__c contrato, Analise_de_credito__c adc, LAT_Opportunity__c opp) {
		if (Client != null) {
			return Client.id;
		} else if (Seg != null) {
			return Seg.LAT_BR_Client__c;
		} else if (contrato != null) {
			return contrato.Account__c;
		} else if (cas != null && cas.LAT_Account__c!=null) {
			return cas.LAT_Account__c;
		} else if (adc != null) {
			return adc.Conta__c;	
		} else if (opp != null && opp.LAT_Account__c !=null) {
			return opp.LAT_Account__c;	
		} else {
			return '-';
		}

	}

	
	private String buildQuery(reportFilters filters) {
		

		String returnQueryStart = this.baseQueryStart;
		String returnRelatedQuery = this.baseRelatedQuery;
		String returnQueryEnd = this.baseQueryEnd;

		if (filters.createdByRegional.Regional_de_vendas__c != null 
			&& filters.createdByRegional.Regional_de_vendas__c != '') {
			returnQueryEnd += 'AND CreatedBy.Regional_de_vendas__c = \'' + filters.createdByRegional.Regional_de_vendas__c + '\' ';
		}
		system.debug('clientId---->' + filters.Client.ParentId);
		if (filters.client.ParentId != null) {
			returnQueryEnd += 'AND TargetObjectId = \'' + filters.client.ParentId + '\' ';
		}
		if (filters.relatedTo != null 
			&& filters.relatedTo != '') {
			returnQueryEnd += 'AND TargetObject.Name = \'' + filters.relatedTo + '\' ';
		}
		
		String auxRelated = '';
		if (filters.currentApprover.OwnerId != null) {
			auxRelated += 'ActorId = \'' + filters.currentApprover.OwnerId + '\' ';
		}
		if (Test.isRunningTest()) {
			returnQueryEnd += ' LIMIT 4000';
		}
		if (filters.DateStart.CloseDate != null) {
			Datetime dtStart = datetime.newInstance(filters.DateStart.CloseDate.year(), filters.DateStart.CloseDate.month(),filters.DateStart.CloseDate.day());
			auxRelated = auxRelated.contains('=')  ? auxRelated + 'AND createdDate >= ' + dtStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ' 
							: auxRelated + 'createdDate >= ' + dtStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ';
		}
		if (filters.DateEnd.CloseDate != null) {
			Datetime dtEnd = datetime.newInstance(filters.DateEnd.CloseDate.year(), filters.DateEnd.CloseDate.month(), filters.DateEnd.CloseDate.day());
			auxRelated = auxRelated.contains('=') ? auxRelated + 'AND createdDate <= ' + dtEnd.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ' 
							: auxRelated + 'createdDate <= ' + dtEnd.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ';
		}
		

		if (auxRelated != '') {
			returnRelatedQuery = returnRelatedQuery.replace('{0}', 'WHERE ' + auxRelated);
		} else {
			returnRelatedQuery = returnRelatedQuery.replace('{0}', '');
		}

		String returnQuery = returnQueryStart + returnRelatedQuery + returnQueryEnd;
		system.debug('Query------>' + returnQuery);

		return returnQuery;
	}

    //MIGRATED 03/11/2016
	private String buildQuery (LAT_reportFilters LAT_filters) {
		
		String returnQueryStart = this.baseQueryStart;
		String returnRelatedQuery = this.baseRelatedQuery;
		String returnQueryEnd = this.baseQueryEnd;

		if (LAT_filters.createdByRegional.Regional_de_vendas__c != null 
			&& LAT_filters.createdByRegional.Regional_de_vendas__c != '') {
			returnQueryEnd += 'AND CreatedBy.Regional_de_vendas__c = \'' + LAT_filters.createdByRegional.Regional_de_vendas__c + '\' ';
		}
		system.debug('clientId---->' + LAT_filters.Client.ParentId);
		if (LAT_filters.client.ParentId != null) {
			returnQueryEnd += 'AND TargetObjectId = \'' + LAT_filters.client.ParentId + '\' ';
		}
		if (LAT_filters.relatedTo != null 
			&& LAT_filters.relatedTo != '') {
			returnQueryEnd += 'AND TargetObject.Name = \'' + LAT_filters.relatedTo + '\' ';
		}
		
		String auxRelated = '';
		if (LAT_filters.currentApprover.OwnerId != null) {
			auxRelated += 'ActorId = \'' + LAT_filters.currentApprover.OwnerId + '\' ';
		}
		if (LAT_filters.DateStart.LAT_CloseDate__c != null) {
			Datetime dtStart = datetime.newInstance(LAT_filters.DateStart.LAT_CloseDate__c.year(), LAT_filters.DateStart.LAT_CloseDate__c.month(),LAT_filters.DateStart.LAT_CloseDate__c.day());
			auxRelated = auxRelated.contains('=')  ? auxRelated + 'AND createdDate >= ' + dtStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ' 
							: auxRelated + 'createdDate >= ' + dtStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ';
		}
		if (LAT_filters.DateEnd.LAT_CloseDate__c != null) {
			Datetime dtEnd = datetime.newInstance(LAT_filters.DateEnd.LAT_CloseDate__c.year(), LAT_filters.DateEnd.LAT_CloseDate__c.month(), LAT_filters.DateEnd.LAT_CloseDate__c.day());
			auxRelated = auxRelated.contains('=') ? auxRelated + 'AND createdDate <= ' + dtEnd.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ' 
							: auxRelated + 'createdDate <= ' + dtEnd.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' ';
		}


		if (auxRelated != '') {
			returnRelatedQuery = returnRelatedQuery.replace('{0}', 'WHERE ' + auxRelated);
		} else {
			returnRelatedQuery = returnRelatedQuery.replace('{0}', '');
		}

		String returnQuery = returnQueryStart + returnRelatedQuery + returnQueryEnd;
		system.debug('Query------>' + returnQuery);

		return returnQuery;
		
	}
	//Wrapper Inner class to display data in page
    public class approvalWrapper {

        public string currentApprover			{get;set;}
        public string client					{get;set;}
        public string clientRating				{get;set;}
        public string relatedTo					{get;set;}
        public string type						{get;set;}
        public string lastApprover				{get;set;}
        public string createdBy 				{get;set;}
        public string createdByRegional			{get;set;}
        public dateTime receivingDate			{get;set;}
        public string justificationSeg			{get;set;} 
        public string relatedId					{get;set;}
        public string clientId					{get;set;}

        public approvalWrapper (String currentApprover, String client, String clientRating, String relatedTo,
        						String type, String lastApprover, String createdBy, String createdByRegional,
        						DateTime receivingDate, String justificationSeg, string relatedId, string clientId){
            this.currentApprover = currentApprover;
            this.client = client;
            this.clientRating = clientRating;
            this.relatedTo = relatedTo;
            this.type = type;
            this.lastApprover = lastApprover;
            this.createdBy = createdBy;
            this.createdByRegional = createdByRegional;
            this.receivingDate = receivingDate;
            this.justificationSeg = justificationSeg;
            this.relatedId = relatedId;
            this.clientId = clientId;
        }
    }

	//Wrapper Inner class report filters
    public class reportFilters {

        public User createdByRegional	{get;set;}
        public Account currentApprover	{get;set;}
        public Account client			{get;set;}
        public string relatedTo			{get;set;}
        public Opportunity DateStart		{get;set;}
        public Opportunity DateEnd			{get;set;}

        
        public reportFilters (){
            this.createdByRegional = new User();
            this.currentApprover = new Account();
            this.client = new Account();
            this.relatedTo = '';
            this.DateStart = new Opportunity();
            this.DateEnd = new Opportunity();
        }
    }

    //Wrapper Inner class report filters
    //MIGRATED 03/11/2016
    public class LAT_reportFilters {

        public User createdByRegional	{get;set;}
        public Account currentApprover	{get;set;}
        public Account client			{get;set;}
        public string relatedTo			{get;set;}
        public LAT_Opportunity__c DateStart		{get;set;}
        public LAT_Opportunity__c DateEnd			{get;set;}

        
        public LAT_reportFilters (){
            this.createdByRegional = new User();
            this.currentApprover = new Account();
            this.client = new Account();
            this.relatedTo = '';
            this.DateStart = new LAT_Opportunity__c();
            this.DateEnd = new LAT_Opportunity__c();
        }
    }

}