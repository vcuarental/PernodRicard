global class EUR_CRM_POSMaterialPIMImagesBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

//    Database.executeBatch(new EUR_CRM_POSMaterialPIMImagesBatch(), 10);
//    Database.executeBatch(new EUR_CRM_POSMaterialPIMImagesBatch('RU'), 10);

	private static final String URL_BASE_1 = 'https://assets.pernod-ricard.io/pim/production/v2/';
	private static final String URL_BASE_2 = 'http://posm-on.prrouss.ru/';

	private String countryCode;

	global EUR_CRM_POSMaterialPIMImagesBatch() {}

	global EUR_CRM_POSMaterialPIMImagesBatch(String countryCode) {
		this.countryCode = countryCode;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		if (this.countryCode != null) {
			this.writeInfoAboutStartRunningFor(countryCode);

			String rtDevName = this.getRtDevNameByCountryCode(countryCode);
			return Database.getQueryLocator([
				SELECT Id
					,   EUR_CRM_POSM_Image_URL__c
					,   EUR_CRM_External_ID__c
					,   EUR_CRM_ImageID__c
					,   (
					SELECT Id
						,   Name
					FROM Attachments
					WHERE ContentType = 'image/png'
				)
				FROM EUR_CRM_POS_Material__c
				WHERE (
					EUR_CRM_POSM_Image_URL__c LIKE :URL_BASE_1 + '%' OR
					EUR_CRM_POSM_Image_URL__c LIKE :URL_BASE_2 + '%'
				)
				AND RecordType.DeveloperName = :rtDevName
			]);
		}

		this.writeInfoAboutStartRunningFor('All');

		return Database.getQueryLocator([
			SELECT Id
				,   EUR_CRM_POSM_Image_URL__c
				,   EUR_CRM_External_ID__c
				,   EUR_CRM_ImageID__c
				,   (
				SELECT Id
					,   Name
				FROM Attachments
				WHERE ContentType = 'image/png'
			)
			FROM EUR_CRM_POS_Material__c
			WHERE (
				EUR_CRM_POSM_Image_URL__c LIKE :URL_BASE_1 + '%' OR
				EUR_CRM_POSM_Image_URL__c LIKE :URL_BASE_2 + '%'
			)
		]);
	}

	global void execute(Database.BatchableContext BC, List<EUR_CRM_POS_Material__c> posms) {
		System.debug('\n\n posms.size() => ' + JSON.serializePretty(posms.size()) + '\n');

		List<Attachment> attachmentsToInsert = new List<Attachment>();
		List<Attachment> attachmentsToDelete = new List<Attachment>();
		for (EUR_CRM_POS_Material__c posm : posms) {
			HttpRequest req = this.makeRequest(posm.EUR_CRM_POSM_Image_URL__c);
			System.debug('\n\n req => ' + req + '\n');

			HttpResponse res = new Http().send(req);
			System.debug('\n\n res => ' + res + '\n');

			Blob image = res.getBodyAsBlob();
			if (image == null) { continue; }

			attachmentsToInsert.add(this.makeAttachment(posm, image));
			attachmentsToDelete.addAll(posm.Attachments);
		}
		this.upsertRecords(attachmentsToInsert);

		this.deleteRecords(attachmentsToDelete);
	}

	global override void finish(Database.BatchableContext BC) {
		this.writeInfoAboutFinishRunningFor(this.countryCode != null ? this.countryCode : 'All');
		this.sendEmailReport(BC);
	}


	/* ========================================================= */
	/*     Helpers
	/* ========================================================= */
	private String getRtDevNameByCountryCode(String countryCode) {
		Map<String, RecordTypeInfo> rtInfoByDN = SObjectType.EUR_CRM_POS_Material__c.getRecordTypeInfosByDeveloperName();
		for (String devName : rtInfoByDN.keySet()) {
			if (devName.containsIgnoreCase(countryCode)) {
				return devName;
			}
		}
		return '';
	}

	private void writeInfoAboutStartRunningFor(String countryCode) {
		EUR_CRM_PIMIntegrRunBatchesWrapper runBatchesWrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
		runBatchesWrapper.addCountryCodeForImagesForPOSMaterials(countryCode);
	}

	private void writeInfoAboutFinishRunningFor(String countryCode) {
		EUR_CRM_PIMIntegrRunBatchesWrapper runBatchesWrapper = new EUR_CRM_PIMIntegrRunBatchesWrapper();
		runBatchesWrapper.removeCountryCodeForImagesForPOSMaterials(countryCode);
	}

	private HttpRequest makeRequest(String imageURL) {
		HttpRequest request = new HttpRequest();

		imageURL = imageURL.replace(' ', '%20');
		request.setEndpoint(imageURL);

		request.setMethod('GET');
		request.setHeader('Content-Type', 'image/jpeg');
		request.setCompressed(true);
		request.setTimeout(60000);

		return request;
	}

	private Attachment makeAttachment(EUR_CRM_POS_Material__c posm, Blob image) {
		return new Attachment(
			ParentId = posm.Id
		,   Name = this.getNormalizedName(posm)
		,   Body = image
		,   ContentType = 'image/png'
		);
	}

	private String getNormalizedName(EUR_CRM_POS_Material__c posm) {
		return posm.EUR_CRM_ImageID__c + '.png';
	}

}