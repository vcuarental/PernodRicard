public with sharing class LAT_ADM_MonitorETLEmail {

	private Map<String, LAT_ADM_MonitorETL.LoadInfo> info;
	private LAT_ADM_MonitorETL monitor;

	public LAT_ADM_MonitorETLEmail() {
		
	}

	/* This method query all the info and send the email */
	public void sendStatusEmail() {
		monitor = new LAT_ADM_MonitorETL();
		info = monitor.doMonitor();
		String[] toAddresses = LAT_GeneralConfigDao.getValueAsStringArray('MONITOR_ETL_RECEIPT',',');
		sendEmail(toAddresses);
	}

	private void sendEmail(String[] toAddresses) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setSubject('ETL Monitor (' + URL.getSalesforceBaseUrl().getHost() + ')');
		mail.setHtmlBody(prepareBody());

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	private String prepareBody() {
		String msg = '<span style="font-family:monospace"><h1>ETL Updated Objects in SFDC</h1>';
		
		msg += prepareCountry('1', 'Brasil');
		msg += prepareCountry('5', 'Uruguay');
		msg += prepareCountry('6', 'Argentina');
		msg += prepareCountry('12', 'Mexico');

		msg += '</span>';
		msg += '<p style="font-family:monospace;font-size:small">Created on: '+ Datetime.now() + ' (GMT)</p>';
		return msg;
	}

	/* This method generates the HTML email based on the information. Modify this method to include new information */
	private String prepareCountry (String ctry, String name) {

		String color; 

		String msg = '<h3>' + name + '</h3>';
		msg += '<ul>';
		for (String dataKey : monitor.ALL_KEYS) {
			LAT_ADM_MonitorETL.LoadInfo i = info.get(monitor.getKey(ctry, dataKey));
			color = pickColor(i.getStatus());
			msg += '<li>';
			msg += '<span style="color:' + color + ';font-weight:bold">' + String.valueOf(i.getStatus()).leftPad(8).escapeHtml4() + '</span>';
			msg += ' - ' + dataKey;
			msg += ' (' + i.getLastDate() + ')';
			msg += '</li>'; 
		}
		msg += '</ul>';
		return msg;
	}

	private String pickColor(LAT_ADM_MonitorETL.WarningLevel level) {
		String color;
		if (LAT_ADM_MonitorETL.WarningLevel.OK == level) {
			color = '#5FB404';
		} else if (LAT_ADM_MonitorETL.WarningLevel.WARNING == level) {
			color = '#FE9A2E';
		} else if (LAT_ADM_MonitorETL.WarningLevel.CRITICAL == level) {
			color = 'red';
		} else {
			color = '#6E6E6E';
		}
		return color;
	}
}