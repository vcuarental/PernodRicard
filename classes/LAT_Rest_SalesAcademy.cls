@RestResource(urlMapping='/LAT_Rest_SalesAcademy/*')
global with sharing class LAT_Rest_SalesAcademy {
	
	public class Retorno {
		public Retorno(List<LAT_SalesAcademyHandler> recs){
			totalSize = recs.size();
			done = true;
			records = recs;
		}
		public Integer totalSize;
		public Boolean done;
		public String nextRecordsUrl;
		public List<LAT_SalesAcademyHandler> records;
	}

	@HttpGet
    global static void doGet(){ 
    	Set<Id> actionPlansIds = new Set<Id>();
    	Set<Id> swotAnalisysIds = new Set<Id>();
    	Set<Id> objetiveDefinitionsIds = new Set<Id>();

    	List<LAT_SalesAcademy__c> headers = [SELECT Id, Name, Account__c, Account__r.Name, Date__c , RecordtypeId, Recordtype.DeveloperName, Status__c,
    										(SELECT Id, RecordtypeId, Recordtype.DeveloperName, Name, Comercial_Adhesion__c, Shopper__c, Distribution_Situation__c, Visibility_Situation__c, Price_Situation__c,
    										Promotion_Situation__c, Recomendation_Situation__c, Positive_Situation__c, Experience_Situation__c, Distribution_Cause__c, Visibility_Cause__c, Price_Cause__c,
    										Promotion_Cause__c, Recomendation_Cause__c, Positive_Cause__c, Experience_Cause__c, Strategic_Plan__c, Goals_Plan__c, Challenges_Plan__c, Strengths_Plan__c, Priorities__c,
    										Team_Training__c, Customer_Services__c, Logistic__c, Brigade_Training__c, Customer_Participation__c FROM Analise_do_Cliente__r),
    										(SELECT Id, RecordtypeId, Recordtype.DeveloperName, Name, Description_Threats__c, Description_Strengths__c, Description_weaknesses__c, Description_Opportunities__c FROM Analise_SWOT__r),
    										(SELECT id, RecordtypeId, Recordtype.DeveloperName, Name, Opportunity_setting__c FROM ObjetivesDefinition__r),
    										(SELECT id, RecordtypeId, Recordtype.DeveloperName, Name, Objective__c, Indicator__c FROM ActionPlans__r) 
    										FROM LAT_SalesAcademy__c];

	    for(LAT_SalesAcademy__c header : headers) {
	    	if(header.Analise_SWOT__r != null){
	    		for (LAT_SWOTAnalysis__c sw : header.Analise_SWOT__r){
	    			swotAnalisysIds.add(sw.Id);
	    		}
	    	}
	    	if(header.ObjetivesDefinition__r != null){
	    		for (LAT_ObjectivesDefinition__c sw : header.ObjetivesDefinition__r){
	    			objetiveDefinitionsIds.add(sw.Id);
	    		}
	    	}
	    	if(header.ActionPlans__r != null){
	    		for (LAT_ActionPlan__c sw : header.ActionPlans__r){
	    			actionPlansIds.add(sw.Id);
	    		}
	    	}
	    }

	    Map<Id, LAT_SWOTAnalysis__c> swotAnalisys = new Map<Id, LAT_SWOTAnalysis__c>([SELECT Id, (SELECT Id, Swot__c, Description__c FROM Focos__r) FROM LAT_SWOTAnalysis__c WHERE Id IN :swotAnalisysIds]);
	    Map<Id, LAT_ActionPlan__c> actionPlans = new Map<Id, LAT_ActionPlan__c>([SELECT Id, (SELECT id, ActionPlan__c, Name, Actions__c, InCharge__c, StartDate__c, EndDate__c, ResourcesPlan__c, ResourcesUsed__c, ActualStatus__c, Notes__c FROM ActionPlans__r) FROM LAT_ActionPlan__c WHERE Id IN:actionPlansIds]);
	    Map<Id, LAT_ObjectivesDefinition__c> objetiveDefinitions = new Map<Id, LAT_ObjectivesDefinition__c>([SELECT Id, (SELECT Objetive__c, id, Name, Negotiation_argument__c, Counterparts__c, Indicators__c, Goal__c, Coverage_goal__c, Value_Box__c, Value_Goal__c, Billing_goal__c, Strategic_objectives__c, Actual_Status__c FROM ObjetivesDefinition__r) FROM LAT_ObjectivesDefinition__c WHERE Id IN :objetiveDefinitionsIds]);

	    List<LAT_SalesAcademyHandler> retorno = new List<LAT_SalesAcademyHandler>();
	    for(LAT_SalesAcademy__c header : headers){
	    	LAT_SalesAcademyHandler ret = new LAT_SalesAcademyHandler();
	    	setHeader(header, ret);
	    	setClientAnalysis(header, ret);
	    	setSWOTAnalysis(header, ret, swotAnalisys);
	    	setObjectivesDefinition(header, ret, objetiveDefinitions);
	    	setActionPlan(header, ret, actionPlans);
	    	retorno.add(ret);
	    }	

	    Retorno ret = new Retorno(retorno);
		RestContext.response.addHeader('Content-Type', 'application/json');
	    RestContext.response.responseBody 	= Blob.valueOf(JSON.serialize(ret));
		RestContext.response.statusCode 	= 200;
	}

    @HttpPost
    global static void POST() {
        RestRequest req = RestContext.request;
        LAT_SalesAcademyHandler academia = (LAT_SalesAcademyHandler)System.JSON.deserialize(req.requestBody.toString(), LAT_SalesAcademyHandler.class);
        System.debug('Academia : ' + academia);

        String res = doUpsert(academia);
        Boolean success = false;
        String idAcademia = '';

        if (res == '') {
        	success = true;
        	idAcademia = academia.header.Id;
        }

        LAT_Rest_Contracts.ServiceResponse response = new LAT_Rest_Contracts.ServiceResponse(idAcademia, res, success);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(response));

        System.debug('response : ' + response);
        if (response.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
	}

    @HttpPut
    global static void PUT() {
        RestRequest req = RestContext.request;
        LAT_SalesAcademyHandler academia = (LAT_SalesAcademyHandler)System.JSON.deserialize(req.requestBody.toString(), LAT_SalesAcademyHandler.class);
        System.debug('Academia : ' + academia);

        String res = doUpsert(academia);
        Boolean success = false;
        String idAcademia = '';

        if (res == '') {
        	success = true;
        	idAcademia = academia.header.Id;
        }

        LAT_Rest_Contracts.ServiceResponse response = new LAT_Rest_Contracts.ServiceResponse(idAcademia, res, success);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(response));

        System.debug('response : ' + response);
        if (response.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }
	}
	
	public static String doUpsert(LAT_SalesAcademyHandler academia) {
		String retorno = '';

		try {
			upsertHeader(academia); 
			upsertClientAnalysis(academia); 
			upsertSWOTAnalysis(academia); 
			upsertObjectivesDefinition(academia);
			upsertActionPlan(academia);

		} catch (DMLException e){
            System.debug('Exception e : ' + e);
            //Added check for FIELD_CUSTOM_VALIDATION_EXCEPTION to return user friendly error.
            String errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                retorno = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            } else {
                retorno = errorMsg;
            }
        } catch (Exception e) {
            System.debug('Exception e2: ' + e);
            System.debug('Exception e2: ' + e.getStackTraceString());
            System.debug('Exception e2: ' + e.getMessage());
            System.debug('Exception e2: ' + e.getCause());
			retorno = ''+ String.valueOf(e.getMessage());
		}

		return retorno;
	}

	public static void upsertActionPlan(LAT_SalesAcademyHandler academia) {

	   	for(LAT_SalesAcademyHandler.Action_Plan ap : academia.Action_Plan) {

	   		LAT_ActionPlan__c nuevo = new LAT_ActionPlan__c();
	   		if(ap.id == null) {
	   			ap.Id = 'nuevo';
	   		}
	   		if(ap.id.startsWith('aQk')) {
	   			nuevo.Id = ap.id;
	   		} else {
	   			nuevo.SalesAcademy__c = academia.header.Id;
	   		}
	   		if(ap.RecordtypeId != null && ap.RecordtypeId != '') nuevo.RecordtypeId = ap.RecordtypeId;
	   		if(ap.objective != null && ap.objective != '') nuevo.Objective__c = ap.objective;
	   		if(ap.indicator != null && ap.indicator != '') nuevo.Indicator__c = ap.indicator;

	   		upsert nuevo;
	   		ap.Id = nuevo.Id;

			List<LAT_Action__c> lineItems = new List<LAT_Action__c>();
			for(LAT_SalesAcademyHandler.Actions ac : ap.Actions) {
				LAT_Action__c nuevaLinea = new LAT_Action__c();
				if(ac.id == null) {
		   			ac.Id = 'nuevo';
		   		}
				if(ac.id.startsWith('aQj')) {
		   			nuevaLinea.Id = ac.id;
		   		} else {
		   			nuevaLinea.ActionPlan__c = ap.Id;
		   		}
		   		if(ac.actions != null && ac.actions != '') nuevaLinea.Actions__c = ac.actions;
		   		if(ac.inCharge != null && ac.inCharge != '') nuevaLinea.InCharge__c = ac.inCharge;
		   		if(ac.startDate != null && ac.startDate != '') nuevaLinea.StartDate__c = Date.valueOf(ac.startDate);
		   		if(ac.endDate != null && ac.endDate != '') nuevaLinea.EndDate__c = Date.valueOf(ac.endDate);
		   		if(ac.resourcesPlan != null && ac.resourcesPlan != '') nuevaLinea.ResourcesPlan__c = ac.resourcesPlan;
		   		if(ac.resourcesUsed != null && ac.resourcesUsed != '') nuevaLinea.ResourcesUsed__c = ac.resourcesUsed;
		   		if(ac.actualStatus != null && ac.actualStatus != '') nuevaLinea.ActualStatus__c = ac.actualStatus;
		   		if(ac.notes != null && ac.notes != '') nuevaLinea.Notes__c = ac.notes;
				
				lineItems.add(nuevaLinea);
			}
			if(lineItems.size() > 0){
				upsert lineItems;
			}

	   	}

	}

	public static void upsertObjectivesDefinition(LAT_SalesAcademyHandler academia) {

	   	for(LAT_SalesAcademyHandler.Objectives_Definition od : academia.Objectives_Definition) {

	   		LAT_ObjectivesDefinition__c nuevo = new LAT_ObjectivesDefinition__c();
	   		if(od.id == null) {
	   			od.Id = 'nuevo';
	   		}
	   		if(od.id.startsWith('aQq')) {
	   			nuevo.Id = od.id;
	   		} else {
	   			nuevo.SalesAcademy__c = academia.header.Id;
	   		}
	   		if(od.RecordtypeId != null && od.RecordtypeId != '') nuevo.RecordtypeId = od.RecordtypeId;
	   		if(od.opportunitySetting != null && od.opportunitySetting != '') nuevo.Opportunity_setting__c = od.opportunitySetting;
			
	   		upsert nuevo;
	   		od.Id = nuevo.Id;

			List<LAT_StrategicObjectives__c> lineItems = new List<LAT_StrategicObjectives__c>();
			for(LAT_SalesAcademyHandler.Strategic_Objectives so : od.Strategic_Objectives) {
				LAT_StrategicObjectives__c nuevaLinea = new LAT_StrategicObjectives__c();
				if(so.id == null) {
		   			so.Id = 'nuevo';
		   		}
				if(so.id.startsWith('aQj')) {
		   			nuevaLinea.Id = so.id;
		   		} else {
		   			nuevaLinea.Objetive__c = od.Id;
		   		}
		   		if(so.negotiationArgument != null && so.negotiationArgument != '') nuevaLinea.Negotiation_argument__c = so.negotiationArgument;
		   		if(so.counterparts != null && so.counterparts != '') nuevaLinea.Counterparts__c = so.counterparts;
		   		if(so.indicators != null && so.indicators != '') nuevaLinea.Indicators__c = so.indicators;
		   		if(so.coverageGoal != null && so.coverageGoal != '') nuevaLinea.Coverage_goal__c = so.coverageGoal;
		   		if(so.valueBox != null && so.valueBox != '') nuevaLinea.Value_Box__c = so.valueBox;
		   		if(so.valueGoal != null && so.valueGoal != '') nuevaLinea.Value_Goal__c = so.valueGoal;
		   		if(so.billingGoal != null && so.billingGoal != '') nuevaLinea.Strategic_objectives__c = so.billingGoal;
		   		if(so.strategicObjetives != null && so.strategicObjetives != '') nuevaLinea.Negotiation_argument__c = so.strategicObjetives;
		   		if(so.actualStatus != null && so.actualStatus != '') nuevaLinea.Actual_Status__c = so.actualStatus;
		   		if(so.goal != null && so.goal != '') nuevaLinea.Goal__c = so.goal;
				
				lineItems.add(nuevaLinea);
			}
			if(lineItems.size() > 0){
				upsert lineItems;
			}

	   	}

	}

	public static void upsertSWOTAnalysis(LAT_SalesAcademyHandler academia) {

	   	for(LAT_SalesAcademyHandler.SWOT_Analysis sw : academia.SWOT_Analysis) {

	   		LAT_SWOTAnalysis__c nuevo = new LAT_SWOTAnalysis__c();
	   		if(sw.id == null) {
	   			sw.Id = 'nuevo';
	   		}
	   		if(sw.id.startsWith('aQn')) {
	   			nuevo.Id = sw.id;
	   		} else {
	   			nuevo.SalesAcademy__c = academia.header.Id;
	   		}
	   		if(sw.RecordtypeId != null && sw.RecordtypeId != '') nuevo.RecordtypeId = sw.RecordtypeId;
	   		if(sw.threats != null && sw.threats != '') nuevo.Description_Threats__c = sw.threats;
	   		if(sw.strenghts != null && sw.strenghts != '') nuevo.Description_Strengths__c = sw.strenghts;
	   		if(sw.weaknesses != null && sw.weaknesses != '') nuevo.Description_weaknesses__c = sw.weaknesses;
	   		if(sw.descriptionOpportunities != null && sw.descriptionOpportunities != '') nuevo.Description_Opportunities__c = sw.descriptionOpportunities;
	   		if(sw.RecordtypeId != null && sw.RecordtypeId != '') nuevo.RecordtypeId = sw.RecordtypeId;
	   		if(sw.RecordtypeId != null && sw.RecordtypeId != '') nuevo.RecordtypeId = sw.RecordtypeId;
	   		if(sw.RecordtypeId != null && sw.RecordtypeId != '') nuevo.RecordtypeId = sw.RecordtypeId;
	   		if(sw.RecordtypeId != null && sw.RecordtypeId != '') nuevo.RecordtypeId = sw.RecordtypeId;

	   		upsert nuevo;
	   		sw.Id = nuevo.Id;

			List<LAT_ActionFocus__c> lineItems = new List<LAT_ActionFocus__c>();
			for(LAT_SalesAcademyHandler.Action_Focus af : sw.Action_Focus) {
				LAT_ActionFocus__c nuevaLinea = new LAT_ActionFocus__c();
				if(af.id == null) {
		   			af.Id = 'nuevo';
		   		}
				if(sw.id.startsWith('aQj')) {
		   			nuevaLinea.Id = af.id;
		   		} else {
		   			nuevaLinea.Swot__c = sw.Id;
		   		}
		   		if(af.description != null && af.description != '') nuevaLinea.Description__c = af.description;
				
				lineItems.add(nuevaLinea);
			}
			if(lineItems.size() > 0){
				upsert lineItems;
			}

	   	}

	}

	public static void upsertClientAnalysis(LAT_SalesAcademyHandler academia) {
		List<LAT_ClientAnalysis__c> lines = new List<LAT_ClientAnalysis__c>();

	   	for(LAT_SalesAcademyHandler.Client_Analysis ca : academia.Client_Analysis) {

	   		LAT_ClientAnalysis__c nuevo = new LAT_ClientAnalysis__c();
	   		if(ca.id == null) {
	   			ca.Id = 'nuevo';
	   		}
	   		if(ca.id.startsWith('aQn')) {
	   			nuevo.Id = ca.id;
	   		} else {
	   			nuevo.SalesAcademy__c = academia.header.Id;
	   		}
	   		if(ca.RecordtypeId != null && ca.RecordtypeId != '') nuevo.RecordtypeId = ca.RecordtypeId;
	   		if(ca.comercialAdhesion != null && ca.comercialAdhesion != '') nuevo.Comercial_Adhesion__c = ca.comercialAdhesion;
	   		if(ca.shopper != null && ca.shopper != '') nuevo.Shopper__c = ca.shopper;
	   		if(ca.distributionSituation != null && ca.distributionSituation != '') nuevo.Distribution_Situation__c = ca.distributionSituation;
	   		if(ca.visibilitySituation != null && ca.visibilitySituation != '') nuevo.Visibility_Situation__c = ca.visibilitySituation;
	   		if(ca.priceSituation != null && ca.priceSituation != '') nuevo.Price_Situation__c = ca.priceSituation;
	   		if(ca.promotionSituation != null && ca.promotionSituation != '') nuevo.Promotion_Situation__c = ca.promotionSituation;
	   		if(ca.recomendationSituation != null && ca.recomendationSituation != '') nuevo.Recomendation_Situation__c = ca.recomendationSituation;
	   		if(ca.positiveSituation != null && ca.positiveSituation != '') nuevo.Positive_Situation__c = ca.positiveSituation;
	   		if(ca.experienceSituation != null && ca.experienceSituation != '') nuevo.Experience_Situation__c = ca.experienceSituation;
	   		if(ca.distributionCause != null && ca.distributionCause != '') nuevo.Distribution_Cause__c = ca.distributionCause;
	   		if(ca.visibilityCause != null && ca.visibilityCause != '') nuevo.Visibility_Cause__c = ca.visibilityCause;
	   		if(ca.priceCause != null && ca.priceCause != '') nuevo.Promotion_Cause__c = ca.priceCause;
	   		if(ca.promotionCause != null && ca.promotionCause != '') nuevo.Recomendation_Cause__c = ca.promotionCause;
	   		if(ca.recomendationCause != null && ca.recomendationCause != '') nuevo.RecordtypeId = ca.recomendationCause;
	   		if(ca.positiveCause != null && ca.positiveCause != '') nuevo.Positive_Cause__c = ca.positiveCause;
	   		if(ca.experienceCause != null && ca.experienceCause != '') nuevo.Experience_Cause__c = ca.experienceCause;
	   		if(ca.strategicPlan != null && ca.strategicPlan != '') nuevo.Strategic_Plan__c = ca.strategicPlan;
	   		if(ca.goalsPlan != null && ca.goalsPlan != '') nuevo.Goals_Plan__c = ca.goalsPlan;
	   		if(ca.challengesPlan != null && ca.challengesPlan != '') nuevo.Challenges_Plan__c = ca.challengesPlan;
	   		if(ca.strengthsPlan != null && ca.strengthsPlan != '') nuevo.Strengths_Plan__c = ca.strengthsPlan;
	   		if(ca.priorities != null && ca.priorities != '') nuevo.Priorities__c = ca.priorities;
	   		if(ca.teamTraining != null && ca.teamTraining != '') nuevo.Team_Training__c = ca.teamTraining;
	   		if(ca.customerServices != null && ca.customerServices != '') nuevo.Customer_Services__c = ca.customerServices;
	   		if(ca.logistic != null && ca.logistic != '') nuevo.Logistic__c = ca.logistic;
	   		if(ca.brigadeTraining != null && ca.brigadeTraining != '') nuevo.Brigade_Training__c = ca.brigadeTraining;
	   		if(ca.customerParticipation != null && ca.customerParticipation != '') nuevo.Customer_Participation__c = ca.customerParticipation;
	   		lines.add(nuevo);

	   	}

	   	if(lines.size() > 0) {
	   		upsert lines;
	   	}

	}

	public static void upsertHeader(LAT_SalesAcademyHandler academia) {
		LAT_SalesAcademy__c header = new LAT_SalesAcademy__c();
		header.Account__c	= academia.header.clientId;
		if(academia.header.pDate != null && academia.header.pDate != '') header.Date__c 		= Date.valueOf(academia.header.pDate);
		if(academia.header.recordTypeId != null && academia.header.recordTypeId != '') header.RecordtypeId = academia.header.recordTypeId;
		if(academia.header.status != null && academia.header.status != '') header.Status__c 	= academia.header.status;

		if(academia.header.id != null)
			if(academia.header.id.startsWith('aQs')) header.Id = academia.header.id;
		
		upsert header;
		academia.header.Id = header.Id;

	}

	public static void setHeader(LAT_SalesAcademy__c header, LAT_SalesAcademyHandler retorno){
		LAT_SalesAcademyHandler.Header ret = new LAT_SalesAcademyHandler.Header();
		ret.name 			= header.Name;
		ret.clientId		= header.Account__c;
		ret.clientName		= header.Account__r.Name;
		ret.pDate			= String.valueOf(header.Date__c);
		ret.recordTypeId 	= header.RecordtypeId;
		ret.recordTypeName 	= header.Recordtype.DeveloperName;
		ret.id 				= header.Id;
		ret.status 			= header.Status__c;
		retorno.Header 		= ret;
	}

	public static void setClientAnalysis(LAT_SalesAcademy__c header, LAT_SalesAcademyHandler retorno) {

	   	retorno.Client_Analysis = new List<LAT_SalesAcademyHandler.Client_Analysis>();

	   	for(LAT_ClientAnalysis__c ca : header.Analise_do_Cliente__r) {
	   		LAT_SalesAcademyHandler.Client_Analysis nuevo = new LAT_SalesAcademyHandler.Client_Analysis();
	   		nuevo.id 						= ca.Id;
			nuevo.recordTypeId 				= ca.RecordtypeId;
			nuevo.salesAcademy 				= header.Id;
			nuevo.salesAcademyName			= header.Name;
			nuevo.name 						= ca.Name;
			nuevo.comercialAdhesion 		= ca.Comercial_Adhesion__c;
			nuevo.shopper 					= ca.Shopper__c;
			nuevo.distributionSituation 	= ca.Distribution_Situation__c;
			nuevo.visibilitySituation 		= ca.Visibility_Situation__c;
			nuevo.priceSituation 			= ca.Price_Situation__c;
			nuevo.promotionSituation 		= ca.Promotion_Situation__c;
			nuevo.recomendationSituation 	= ca.Recomendation_Situation__c;
			nuevo.positiveSituation 		= ca.Positive_Situation__c;
			nuevo.experienceSituation 		= ca.Experience_Situation__c;
			nuevo.distributionCause 		= ca.Distribution_Cause__c;
			nuevo.visibilityCause 			= ca.Visibility_Cause__c;
			nuevo.priceCause 				= ca.Price_Cause__c;
			nuevo.promotionCause 			= ca.Promotion_Cause__c;
			nuevo.recomendationCause 		= ca.Recomendation_Cause__c;
			nuevo.positiveCause 			= ca.Positive_Cause__c;
			nuevo.experienceCause 			= ca.Experience_Cause__c;
			nuevo.strategicPlan 			= ca.Strategic_Plan__c;
			nuevo.goalsPlan 				= ca.Goals_Plan__c;
			nuevo.challengesPlan 			= ca.Challenges_Plan__c;
			nuevo.strengthsPlan 			= ca.Strengths_Plan__c;
			nuevo.priorities 				= ca.Priorities__c;
			nuevo.teamTraining 				= ca.Team_Training__c;
			nuevo.customerServices 			= ca.Customer_Services__c;
			nuevo.logistic 					= ca.Logistic__c;
			nuevo.brigadeTraining 			= ca.Brigade_Training__c;
			nuevo.customerParticipation 	= ca.Customer_Participation__c;
			retorno.Client_Analysis.add(nuevo);

	   	}
	}	

	public static void setSWOTAnalysis(LAT_SalesAcademy__c header, LAT_SalesAcademyHandler retorno, Map<Id, LAT_SWOTAnalysis__c> swotAnalisys) {

	   	retorno.SWOT_Analysis = new List<LAT_SalesAcademyHandler.SWOT_Analysis>();

	   	for(LAT_SWOTAnalysis__c ca : header.Analise_SWOT__r) {
	   		LAT_SalesAcademyHandler.SWOT_Analysis nuevo = new LAT_SalesAcademyHandler.SWOT_Analysis();
	   		nuevo.id 						= ca.Id;
			nuevo.recordTypeId 				= ca.RecordtypeId;
			nuevo.recordTypeName 			= ca.Recordtype.DeveloperName;
			nuevo.salesAcademy 				= header.Id;
			nuevo.salesAcademyName			= header.Name;
			nuevo.name 						= ca.Name;
			nuevo.threats 					= ca.Description_Threats__c;
			nuevo.strenghts					= ca.Description_Strengths__c;
			nuevo.weaknesses				= ca.Description_weaknesses__c;
			nuevo.descriptionOpportunities	= ca.Description_Opportunities__c;
			nuevo.Action_Focus = new List<LAT_SalesAcademyHandler.Action_Focus>();
			for(LAT_ActionFocus__c af : swotAnalisys.get(ca.Id).Focos__r) {
				LAT_SalesAcademyHandler.Action_Focus nuevoAf = new LAT_SalesAcademyHandler.Action_Focus();
				nuevoAf.Id 				= af.Id;
				nuevoAf.swotId 			= af.Swot__c;
				nuevoAf.description 	= af.Description__c;
				nuevo.Action_Focus.add(nuevoAf);
			}
			retorno.SWOT_Analysis.add(nuevo);

	   	}
	}

	public static void setObjectivesDefinition(LAT_SalesAcademy__c header, LAT_SalesAcademyHandler retorno, Map<Id, LAT_ObjectivesDefinition__c> objetiveDefinitions) {

	   	retorno.Objectives_Definition = new List<LAT_SalesAcademyHandler.Objectives_Definition>();

	   	for(LAT_ObjectivesDefinition__c ca : header.ObjetivesDefinition__r) {
	   		LAT_SalesAcademyHandler.Objectives_Definition nuevo = new LAT_SalesAcademyHandler.Objectives_Definition();
	   		nuevo.id 						= ca.Id;
			nuevo.recordTypeId 				= ca.RecordtypeId;
			nuevo.recordTypeName 			= ca.Recordtype.DeveloperName;
			nuevo.name 						= ca.Name;
			nuevo.opportunitySetting 		= ca.Opportunity_setting__c;
			nuevo.Strategic_Objectives = new List<LAT_SalesAcademyHandler.Strategic_Objectives>();
			for(LAT_StrategicObjectives__c od : objetiveDefinitions.get(ca.Id).ObjetivesDefinition__r) {
				LAT_SalesAcademyHandler.Strategic_Objectives nuevoOd = new LAT_SalesAcademyHandler.Strategic_Objectives();
				nuevoOd.Id 						= od.Id;
				nuevoOd.objetiveId				= od.Objetive__c;
				nuevoOd.objetiveName 			= od.Name;
				nuevoOd.negotiationArgument 	= od.Negotiation_argument__c;
				nuevoOd.counterparts 			= od.Counterparts__c;
				nuevoOd.indicators 				= od.Indicators__c;
				nuevoOd.coverageGoal 			= od.Coverage_goal__c;
				nuevoOd.valueBox 				= od.Value_Box__c;
				nuevoOd.valueGoal 				= od.Value_Goal__c;
				nuevoOd.billingGoal 			= od.Billing_goal__c;
				nuevoOd.strategicObjetives 		= od.Strategic_objectives__c;
				nuevoOd.actualStatus 			= od.Actual_Status__c;
				nuevoOd.goal 					= od.Goal__c;
				nuevo.Strategic_Objectives.add(nuevoOd);
			}
			retorno.Objectives_Definition.add(nuevo);
	   	}
	}

	public static void setActionPlan(LAT_SalesAcademy__c header, LAT_SalesAcademyHandler retorno, Map<Id, LAT_ActionPlan__c> actionPlans) {

	   	retorno.Action_Plan = new List<LAT_SalesAcademyHandler.Action_Plan>();

	   	for(LAT_ActionPlan__c ca : header.ActionPlans__r) {
	   		LAT_SalesAcademyHandler.Action_Plan nuevo = new LAT_SalesAcademyHandler.Action_Plan();
	   		nuevo.id 						= ca.Id;
			nuevo.recordTypeId 				= ca.RecordtypeId;
			nuevo.recordTypeName 			= ca.Recordtype.DeveloperName;
			nuevo.salesAcademy 				= header.Id;
			nuevo.salesAcademyName			= header.Name;
			nuevo.name 						= ca.Name;
			nuevo.objective 				= ca.Objective__c;
			nuevo.indicator 				= ca.Indicator__c;
			nuevo.Actions = new List<LAT_SalesAcademyHandler.Actions>();
			for(LAT_Action__c ap : actionPlans.get(ca.Id).ActionPlans__r) {
				LAT_SalesAcademyHandler.Actions nuevoAp = new LAT_SalesAcademyHandler.Actions();
				nuevoAp.Id 						= ap.Id;
				nuevoAp.actionPlan 				= ap.ActionPlan__c;
				nuevoAp.actions 				= ap.Actions__c;
				nuevoAp.inCharge 				= ap.InCharge__c;
				nuevoAp.startDate 				= String.valueOf(ap.StartDate__c);
				nuevoAp.endDate 				= String.valueOf(ap.EndDate__c);
				nuevoAp.resourcesPlan 			= ap.ResourcesPlan__c;
				nuevoAp.resourcesUsed 			= ap.ResourcesUsed__c;
				nuevoAp.actualStatus 			= ap.ActualStatus__c;
				nuevoAp.notes 					= ap.Notes__c;
				nuevo.Actions.add(nuevoAp);
			}
			retorno.Action_Plan.add(nuevo);
	   	}
	}
}