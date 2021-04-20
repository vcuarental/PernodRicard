/********************************************************************************
* Interface to Get reports From BI
*
* NAME: LAT_WS_GetBIReportsInterface.cls
* AUTHOR: Mariano Boezio                          
********************************************************************************/
public with sharing class LAT_WS_GetBIReportsInterface {
	
	public LAT_WS_GetBIReportsInterface() {}

	// Returns the string xml returned by BI or the corresponding errorCode
	public static String getBiReportsCallout (Map<String, String> parameters, String reportPath, String Country) {
		try {
			LAT_WS_GetBIReport.GetReportSFDCService request = new LAT_WS_GetBIReport.GetReportSFDCService();

			// Generating ClientInfo
			LAT_WS_GetBIReport.ClientInfoType connParms = new LAT_WS_GetBIReport.ClientInfoType();
			CS001_JDEInterfaceCredentials__c cred = CS001_JDEInterfaceCredentials__c.getInstance(Country);
			if(cred != null){
			  connParms.country      = cred.Country__c;
			  connParms.remoteHostIP = cred.RemoteHostIP__c;
			  connParms.system_x     = cred.System__c;
			  connParms.systemUserID = cred.SystemUserID__c;
			  connParms.time_x       = Datetime.now();
			}

			// Generating ReportRequest
			LAT_WS_GetBIReport.ParamNameValue[] items = new LAT_WS_GetBIReport.ParamNameValue[]{};

			// Set Parameters
			for (String keyValues: parameters.keySet()) {
				LAT_WS_GetBIReport.ParamNameValue param = new LAT_WS_GetBIReport.ParamNameValue();
				param.name = keyValues;
				LAT_WS_GetBIReport.ArrayOfString paramValues = new LAT_WS_GetBIReport.ArrayOfString();
				String[] valueItem = new String[]{parameters.get(keyValues)};
				paramValues.item = valueItem;
				param.values = paramValues;
				items.add(param);
			}

			LAT_WS_GetBIReport.ArrayOfParamNameValue parameterNameValues = new LAT_WS_GetBIReport.ArrayOfParamNameValue();
			parameterNameValues.item = items;

			LAT_WS_GetBIReport.ReportRequest reportRequest = new LAT_WS_GetBIReport.ReportRequest();
			reportRequest.parameterNameValues = parameterNameValues;
			reportRequest.reportAbsolutePath = reportPath;

			system.debug(reportRequest);
			// Send Request
			LAT_WS_GetBIReport.getReportResponse_element response = request.getReport(reportRequest, connParms);

			if (response.errorCode == null) {
				String xmlString = EncodingUtil.base64Decode(response.getReportReturn.reportBytes).toString();
				system.debug('xmlString------>' + xmlString);
				return xmlString;
			} else {
				LAT_DebugUtil debugUtil = new LAT_DebugUtil();
	    		debugUtil.setOrigin('getBiReportsCallout');
	    		debugUtil.addTitle('Error');
	    		debugUtil.addData('ErrorCode: ' + response.errorCode + 
	    								    ' ErrorMessage: ' + response.errorMessage);
			    debugUtil.insertDebug();
			    return response.errorCode;
			}
		} catch (Exception e) {
			LAT_DebugUtil debugUtil = new LAT_DebugUtil();
    		debugUtil.setOrigin('getBiReportsCallout');
    		debugUtil.addTitle('EXCEPTION!');
		    debugUtil.addException(e);
		    debugUtil.insertDebug();
		    return '-1';
		}
	}
}