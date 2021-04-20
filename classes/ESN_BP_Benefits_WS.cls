@RestResource(urlMapping='/ESN_BP_Benefits/*')
global with sharing class ESN_BP_Benefits_WS {


@HttpGet
  global static WSBenefitsList getBenefits() {
       String resultat;
       WSBenefitsList benefits = new WSBenefitsList();
       String function = RestContext.request.params.get('function');
       if(String.isEmpty(function)){
       		function = 'all';
       }
       resultat = ESN_BP_Tools.GetBenefitsFromFunction(function); 
       benefits.benefitsList = resultat.split(';');
       return benefits;

  }

	global class WSBenefitsList {
	    public String[] benefitsList;
	}
}