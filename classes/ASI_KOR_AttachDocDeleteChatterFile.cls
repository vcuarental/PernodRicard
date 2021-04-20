public with sharing class ASI_KOR_AttachDocDeleteChatterFile extends ASI_KOR_TriggerAbstract {

	private static final String ATTACH_FILE_ID_FIELD = 'ASI_KOR_FileId__c';
	
	public ASI_KOR_AttachDocDeleteChatterFile() {
		super('ASI_KOR_AttachDocDeleteChatterFile');
	}
	
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		if (tAction == TriggerAction.AFTER_DELETE) {
			Set<String> contentVerIdSet = new Set<String>();
			for (sObject theDocObj : sObjList) {
				String contentVerId = (String)theDocObj.get(ATTACH_FILE_ID_FIELD);
				if (contentVerId != null && contentVerId.trim() != '') {
					contentVerIdSet.add(contentVerId);
				} else {
					System.debug('No content version Id for object: ' + String.valueOf(theDocObj));
				}
			}
			if (contentVerIdSet.size() > 0) {
				List<ContentVersion> contentVerList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVerIdSet];
				Set<ID> contentDocIdSet = new Set<ID>();
				for (ContentVersion cv : contentVerList) {
					contentDocIdSet.add(cv.ContentDocumentId);
				}
				List<ContentDocument> contentDocList = [SELECT Id FROM ContentDocument WHERE Id IN:contentDocIdSet];
				delete contentDocList;
			}
		}
	}

}