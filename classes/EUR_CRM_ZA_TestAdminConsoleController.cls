@isTest
public class EUR_CRM_ZA_TestAdminConsoleController {
            
	static testMethod void testAdminConsoleController() {
		EUR_CRM_ZA_AdminConsoleController con = new EUR_CRM_ZA_AdminConsoleController();
        
		con.createFollowUp();
		con.getVisitActions();
		con.massUpdateImageLevelThreshold();
		con.massUpdateVolumeLevelThreshold();
		con.massUpdateCriteriaSetImageLevel();
		con.massUpdateCriteriaSetVolumeLevel();

		con.refresh();
		con.deactiveOPMappings();
		con.getSurveyHeaders();
		//con.deactiveSurveys();
	}

}