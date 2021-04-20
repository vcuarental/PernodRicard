@RestResource(urlMapping='/LAT_Rest_GetAvailableCredit/*')
global with sharing class LAT_Rest_GetAvailableCredit {
	
    @HttpPost
    global static LAT_WS_GetAvailableCredit.creditItem getAvailbleCredit(String accountAN8) {
    	return LAT_WS_GetAvailableCredit.getAvailableCredit(accountAN8);
    }
}