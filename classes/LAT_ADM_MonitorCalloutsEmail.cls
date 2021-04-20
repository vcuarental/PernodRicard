public with sharing class LAT_ADM_MonitorCalloutsEmail {
	public LAT_ADM_MonitorCalloutsEmail() {
		
	}

	public Boolean sendEmailIfCritical() {
		String[] toAddresses = LAT_GeneralConfigDao.getValueAsStringArray('MONITOR_CALLOUT_RECEIPT',',');

		String[] allConf = LAT_GeneralConfigDao.getValueAsStringArray('MONITOR_CALLOUT_OPTIONS',',');
		if (toAddresses == null || allConf == null || toAddresses.size() < 1 || allConf.size() != 4) {
			System.debug(LoggingLevel.WARN, 'LAT_ADM_MonitorCalloutsEmail :: Incorrect configuration');
			return false;
		}

		Integer range = Integer.valueOf(allConf[0]);
		Integer min = Integer.valueOf(allConf[1]);
		Integer tlimit = Integer.valueOf(allConf[2]);		
		Integer percentage = Integer.valueOf(allConf[3]);

		Boolean sent = false;
		if (isCritical(range, min, tlimit, percentage)) {
			System.debug('LAT_ADM_MonitorCalloutsEmail.sendEmailIfCritical WARN');
			sendEmail(toAddresses);
			sent = true;
		} else {
			System.debug('LAT_ADM_MonitorCalloutsEmail.sendEmailIfCritical ok');
			sent = false;
		}
		return sent;
	}



	// this method determines if we are in a critical situation or not
	public Boolean isCritical(Integer rangeInMinutes, Integer minCount, Integer timeLimit, Integer percentagePermited) {

		Integer count = 0;
		Integer countWithError = 0;
		Datetime now = Datetime.now();
		Datetime start = now.addMinutes(-1 * rangeInMinutes);
		for (LAT_Log__c logx : [SELECT LAT_DurationInSeconds__c FROM LAT_Log__c where LAT_StartTime__c >= :start and LAT_StartTime__c < :now]) {
			count ++;
			if (logx.LAT_DurationInSeconds__c >= timeLimit) {
				countWithError ++;
			}
		}

		return (count >= minCount) && ((countWithError * 100.0 / count) >= percentagePermited);
	}

	private void sendEmail(String[] toAddresses) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.emailPriority = 'Highest';
		mail.setSubject('Callouts Monitor (' + URL.getSalesforceBaseUrl().getHost() + ')');

		String msg = 'ATENCION: Posible problema en integraciones.';
		msg += 'Las consultas a PriceCalculation estan demorando y posiblemente esten dando TIMEOUT. ';
		msg += 'Reporte sugerido: https://pernod-ricard.my.salesforce.com/00OD00000066ZWS';
		mail.setPlainTextBody(msg);

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}