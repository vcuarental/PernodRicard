/********************************************************************************
*     Company:Valuenet  Developer:Waldemar Mayo    Date:09/12/2013              *
*-------------------------------------------------------------------------------*
*   Esta clase sirve para hacer inserciones en el objeto LAT_DebugInfo__c de    *
*   forma mas simple                                                            *
*********************************************************************************/

public with sharing class LAT_DebugUtil {
    
    private LAT_DebugInfo__c debugInfo;
    private Boolean insertLog;
    private static final String BREAK_LINE = '<br/>';
    
    //Constructor
    public LAT_DebugUtil (){
        this.debugInfo = new LAT_DebugInfo__c();
        this.debugInfo.LAT_DebugData__c = '';
        List<LAT_Info__c> infoList = [SELECT Debug_Logs__c 
                                        FROM LAT_Info__c 
                                        WHERE Name =: 'Settings'];
        this.insertLog = !infoList.isEmpty() ? infoList.get(0).Debug_Logs__c : true;
    }
    
    public void setOrigin(String origin){
        this.debugInfo.LAT_Origin__c = origin;
    }
    
    public void addTitle(String title){
        if(debugInfo.LAT_DebugData__c != ''){
            this.debugInfo.LAT_DebugData__c += '<br/>';
        }
        this.debugInfo.LAT_DebugData__c += '<b><span style="color: blue;">'+title+'</span></b><br/>';
    }
    
    public void addSubTitle(String subTitle){
        this.debugInfo.LAT_DebugData__c += '<b>'+subTitle+'</b><br/>';
    }
    
    public void addData(String label, String textData){
        this.debugInfo.LAT_DebugData__c += '<b>'+label+': </b>'+textData+'<br/>';
    }
    
    public void addData(String textData){
        this.debugInfo.LAT_DebugData__c += textData+'<br/>';
    }

    public void addException (Exception e) {
        this.debugInfo.LAT_DebugData__c += '<b><span style="color: blue;">Exception:</span></b><br/>' + e + BREAK_LINE;
        this.debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Type: '    + e.getTypeName();
        this.debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Line: '    + e.getLineNumber();
        this.debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Cause: '   + e.getCause();
        this.debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Message: ' + e.getMessage();
        this.debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Stack Trace: ' + e.getStackTraceString();
    }
    
    public void setResult(String result){
		this.debugInfo.LAT_ResultCode__c = result;
    }
    
    public void insertDebug(){
        this.checkFieldsLength();
        if (this.insertLog) insert this.debugInfo;

        if(debugInfo.LAT_Origin__c == 'notifyOnTradeChange.EXCEPTION'){
            notifyAccountError(debugInfo.Id);
        }
    }
    
    public void checkFieldsLength(){
    	if(this.debugInfo.LAT_DebugData__c != null){
            this.debugInfo.LAT_DebugData__c = this.debugInfo.LAT_DebugData__c.length()>32000 ? this.debugInfo.LAT_DebugData__c.subString(0, 32000) : this.debugInfo.LAT_DebugData__c;
        }
    	if(this.debugInfo.LAT_Origin__c != null){
            this.debugInfo.LAT_Origin__c = this.debugInfo.LAT_Origin__c.length()>255 ? this.debugInfo.LAT_Origin__c.subString(0, 254) : this.debugInfo.LAT_Origin__c;
        }
    	if(this.debugInfo.LAT_ResultCode__c != null){
            this.debugInfo.LAT_ResultCode__c = this.debugInfo.LAT_ResultCode__c.length()>255 ? this.debugInfo.LAT_ResultCode__c.subString(0, 254) : this.debugInfo.LAT_ResultCode__c;
        }
    }

    public  LAT_DebugInfo__c getDebugInfo(){
        return debugInfo;
    }

    public static void insertDebug(String origin, String logInfo, String resultCode) {
        LAT_DebugInfo__c debugInfo = new LAT_DebugInfo__c();
        debugInfo.LAT_Origin__c = origin;
        debugInfo.LAT_DebugData__c = logInfo;
        debugInfo.LAT_ResultCode__c = resultCode;
        insert debugInfo;
    }

    public static void addException (String origin, Exception e, String resultCode) {
        LAT_DebugInfo__c debugInfo = new LAT_DebugInfo__c();
        debugInfo.LAT_Origin__c = origin;
        debugInfo.LAT_DebugData__c += '<b><span style="color: blue;">Exception:</span></b><br/>' + e + BREAK_LINE;
        debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Type: '    + e.getTypeName();
        debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Line: '    + e.getLineNumber();
        debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Cause: '   + e.getCause();
        debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Message: ' + e.getMessage();
        debugInfo.LAT_DebugData__c += BREAK_LINE + BREAK_LINE + 'Stack Trace: ' + e.getStackTraceString();
        debugInfo.LAT_ResultCode__c = resultCode;
        insert debugInfo;
    }

    public static void clearAllDebugLogs() {
        final List <LAT_DebugInfo__c> logList = [SELECT Id FROM LAT_DebugInfo__c Limit 9999];
        delete logList;
    }

    public void notifyAccountError(String logId) {
            

            String[] emailAddresses = LAT_GeneralConfigDao.getValueAsStringArray('ACCOUNT_NOTIFY_ERROR_MAIL', ';');
            String baseUrl = System.URL.getSalesforceBaseUrl().getHost();

            String emailBody    = '<html><body><b>Ha ocurrido un error al intentar enviar un cliente a integrar:</b> <br> <br> A continuación se brinda el registro de error: ';
            emailBody += 'https://' + baseUrl + '/'+ logId;
            

            emailBody += '</body></html>';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailAddresses);
            mail.setHtmlBody(emailBody);
            mail.setSenderDisplayName('noreply@pernod-ricard.com');
            mail.setSubject('Error al enviar a integrar el cliente al sistema de bonificaciones.');
            
            List<Messaging.SingleEmailMessage> list_emailsToSent = new List<Messaging.SingleEmailMessage>();
            list_emailsToSent.add(mail);    
            
            Messaging.sendEmail(list_emailsToSent);
    }
}