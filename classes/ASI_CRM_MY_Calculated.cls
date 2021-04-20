public with sharing class ASI_CRM_MY_Calculated {
 
    public ASI_CRM_MY_Calculated() {
	
    }
    
    public pageReference executeCalculatedFOC_Schedule(){
		
        ASI_CRM_MY_CalculatedFOC_Schedule calcFOC_Batch = new ASI_CRM_MY_CalculatedFOC_Schedule();
        calcFOC_Batch.genFOC();
        return null;
    }
    
}