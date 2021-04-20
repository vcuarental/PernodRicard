/**
*   Constant class used for reference
*
*/

public with sharing class ESN_BP_Statics {

    public static Set<String> SET_HTML_TAGS_TO_REPLACE_CRLF = new Set<String>{'<br>','<br >', '<br/>','<br />', '</li>','</p>'};
    public static String VOTED_FOR_BP = 'Voted for a best practice';
    public static String MARKETING_FUNCTION = 'Marketing';

    public static String AUTHORIZE_URL = ESN_BP_Settings__c.getValues('AUTHORIZE_URL') != null ? ESN_BP_Settings__c.getValues('AUTHORIZE_URL').Value__c : '';
    public static String TOKEN_URL = ESN_BP_Settings__c.getValues('TOKEN_URL') != null ? ESN_BP_Settings__c.getValues('TOKEN_URL').Value__c : '';
    public static String WEB_SERVER_CONNECTED_APP_CLIENT_ID = ESN_BP_Settings__c.getValues('CONNECTED_APP_CLIENT_ID') != null ? ESN_BP_Settings__c.getValues('CONNECTED_APP_CLIENT_ID').Value__c : '';
    public static String WEB_SERVER_CONNECTED_APP_CLIENT_SECRET = ESN_BP_Settings__c.getValues('CONNECTED_APP_CLIENT_SECRET') != null ? ESN_BP_Settings__c.getValues('CONNECTED_APP_CLIENT_SECRET').Value__c : '';
    public static String WEB_SERVER_CONNECTED_APP_REDIRECT_URI = ESN_BP_Settings__c.getValues('CONNECTED_APP_REDIRECT_URI') != null ? ESN_BP_Settings__c.getValues('CONNECTED_APP_REDIRECT_URI').Value__c : '';
    public static String USER_AGENT_CONNECTED_APP_CLIENT_ID = ESN_BP_Settings__c.getValues('USER_AGENT_CONNECTED_APP_CLIENT_ID') != null ? ESN_BP_Settings__c.getValues('USER_AGENT_CONNECTED_APP_CLIENT_ID').Value__c : '';
    public static String USER_AGENT_CONNECTED_APP_CLIENT_SECRET = ESN_BP_Settings__c.getValues('USER_AGENT_CONNECTED_APP_CLIENT_SECRET') != null ? ESN_BP_Settings__c.getValues('USER_AGENT_CONNECTED_APP_CLIENT_SECRET').Value__c : '';
    public static String USER_AGENT_CONNECTED_APP_REDIRECT_URI = ESN_BP_Settings__c.getValues('USER_AGENT_CONNECTED_APP_REDIRECT_URI') != null ? ESN_BP_Settings__c.getValues('USER_AGENT_CONNECTED_APP_REDIRECT_URI').Value__c : '';
    public static String IE8_VERSION_URL = ESN_BP_Settings__c.getValues('IE8_VERSION_URL') != null ? ESN_BP_Settings__c.getValues('IE8_VERSION_URL').Value__c : '';
}