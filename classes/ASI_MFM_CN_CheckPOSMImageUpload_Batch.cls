Global class ASI_MFM_CN_CheckPOSMImageUpload_Batch implements Database.Batchable<AggregateResult>, Database.Stateful{

    Private Static Final Id CN_MEDIA_P_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Final_Artwork_Photo');
    Private Static Final Id CN_MEDIA_FP_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo');
    Private Static Final Id CN_MEDIA_WP_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo');
    
    Private Static Final Id CN_LOG_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');
    
	Global Iterable<AggregateResult> start(Database.BatchableContext BC){
        system.debug('ASI_MFM_CN_CheckPOSMImageUpload_Batch start');
        return new AggregateResultIterable();
    }
    
    Global void execute(Database.BatchableContext BC, List<AggregateResult> aggregateResultList){
		system.debug('ASI_MFM_CN_CheckPOSMImageUpload_Batch execute');

        AggregateResult aggregateResult = aggregateResultList[0];
        Integer iCount = (Integer)aggregateResult.get('count_doc');
        string sCurDatetime = Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        string sMsg = '\n' + 'Created Date : ' + sCurDatetime + '\n' +
            '# of uploaded documents : ' + iCount + '\n';
        
        ASI_MFM_BatchLog__c oLog = new ASI_MFM_BatchLog__c();
        oLog.RecordTypeId = CN_LOG_RECORD_TYPE_ID;
        oLog.ASI_MFM_LogType__c = 'POSM Image';
        oLog.ASI_MFM_Operation_Error__c = TRUE;
        oLog.ASI_MFM_Operation_Error_Message__c = sMsg;
		insert oLog;
    }
    
    Global void finish(Database.BatchableContext BC){
        system.debug('ASI_MFM_CN_CheckPOSMImageUpload_Batch finish');
    }

    global class AggregateResultIterable implements Iterable<AggregateResult> {
        global Iterator<AggregateResult> iterator() {
            return new AggregateResultIterator();
        }
    }
    
	global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results { get; set; }
        Integer index { get; set; }

        global AggregateResultIterator() {
            index = 0;
            results = [
                    SELECT COUNT(Id) count_doc //Id, CreatedBy.Id, CreatedDate
                    FROM ASI_CRM_Product_Warehouse_Photo__c
					WHERE CreatedDate >= N_DAYS_AGO:1
						AND RecordTypeId IN (:CN_MEDIA_P_RECORD_TYPE_ID, :CN_MEDIA_FP_RECORD_TYPE_ID, :CN_MEDIA_WP_RECORD_TYPE_ID)
            ];

        }

        global Boolean hasNext() {
            return results != null && !results.isEmpty() && index < results.size();
        }

        global AggregateResult next() {
            return results[index++];
        }
    }
    
}