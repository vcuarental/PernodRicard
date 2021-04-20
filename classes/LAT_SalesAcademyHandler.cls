public with sharing class LAT_SalesAcademyHandler {

	
	public static LAT_SalesAcademyHandler parse(String json) {
		return (LAT_SalesAcademyHandler) System.JSON.deserialize(json, LAT_SalesAcademyHandler.class);
	}


	public Header Header;
	public List<Client_Analysis> Client_Analysis;
	public List<SWOT_Analysis> SWOT_Analysis;
	public List<Objectives_Definition> Objectives_Definition;
	public List<Action_Plan> Action_Plan;

	public class Header {
		public String name;
		public String clientId;
		public String clientName;
		public String pDate;
		public String recordTypeId;
		public String recordTypeName;
		public String id;
		public String status;
	}

	public class SWOT_Analysis {
		public String id;
		public String recordTypeId;
		public String recordTypeName;
		public String salesAcademy;
		public String salesAcademyName;
		public String name;
		public String threats;
		public String strenghts;
		public String weaknesses;
		public String descriptionOpportunities;
		public List<Action_Focus> Action_Focus;
	}

	public class Objectives_Definition {
		public String id;
		public String opportunitySetting;
		public String recordTypeId;
		public String recordTypeName;
		public String salesAcademy;
		public String name;
		public List<Strategic_Objectives> Strategic_Objectives;
	}

	public class Strategic_Objectives {
		public String id;
		public String objetiveId;
		public String objetiveName;
		public String negotiationArgument;
		public String counterparts;
		public String indicators;
		public String coverageGoal;
		public String valueBox;
		public String valueGoal;
		public String billingGoal;
		public String strategicObjetives;
		public String actualStatus;
		public String goal;
	}

	public class Action_Focus {
		public String id;
		public String swotId;
		public String description;
	}

	public class Actions {
		public String id;
		public String actionPlan;
		public String actions;
		public String inCharge;
		public String startDate;
		public String endDate;
		public String resourcesPlan;
		public String resourcesUsed;
		public String actualStatus;
		public String notes;
	}

	public class Client_Analysis {
		public String id;
		public String recordTypeId;
		public String salesAcademy;
		public String salesAcademyName;
		public String name;
		public String comercialAdhesion;
		public String shopper;
		public String distributionSituation;
		public String visibilitySituation;
		public String priceSituation;
		public String promotionSituation;
		public String recomendationSituation;
		public String positiveSituation;
		public String experienceSituation;
		public String distributionCause;
		public String visibilityCause;
		public String priceCause;
		public String promotionCause;
		public String recomendationCause;
		public String positiveCause;
		public String experienceCause;
		public String strategicPlan;
		public String goalsPlan;
		public String challengesPlan;
		public String strengthsPlan;
		public String priorities;
		public String teamTraining;
		public String customerServices;
		public String logistic;
		public String brigadeTraining;
		public String customerParticipation;
	}

	public class Action_Plan {
		public String id;
		public String recordTypeId;
		public String recordTypeName;
		public String salesAcademy;
		public String salesAcademyName;
		public String name;
		public String objective;
		public String indicator;
		public List<Actions> Actions;
	}

	
}