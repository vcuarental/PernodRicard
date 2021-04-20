/******************************************************************************************
*   Company:Valuenet    Developers:   Denis Aranda                       Date:23/06/2014  *
*******************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
global with sharing class LAT_AR_BTN02_ValidateUserProfile {
	
	webService static String ValidateUserProfile (){
		Set<String> setOfAllowedIds = new Set<String>(); 
		setOfAllowedIds.add(LAT_GlobalProfileCache.getStandardAdminProfileId());
		setOfAllowedIds.add(LAT_GlobalProfileCache.getProfileIdByName('PR BRAZIL System Administrator'));
		setOfAllowedIds.add(LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator'));
		setOfAllowedIds.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator'));
		setOfAllowedIds.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator'));
		String idOfProf = Userinfo.getProfileId();
		if(setOfAllowedIds.contains(idOfProf)){
			return 'true';
		}
		return Label.LAT_AR_BTN03_00001;
		// Label.LAT_AR_BTN03_00001 = "Only system Administrators can execute this action";
	}
	
}