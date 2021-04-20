/**
 * Logger Service for iSPend APP
 *
 * @todo create abstract methods to use the Record Type IDs
 * @author afi
 * @copyright PARX
 */
public class EUR_ISP_LogService
{
	public static final String DE_ERROR_LOG_RT_NAME = 'EUR_ISP_DE_Error_Log';
	public static final String ERROR_LOG_RT_NAME = 'EUR_ISP_iSpend_Error_Log';

	public static final String STATUS_NEW = 'New';
	public static final String TYPE_ERROR = 'Error';
	public static final String TYPE_WARNING = 'Warning';
	public static final String TYPE_SUCCESS = 'Success';

	private static List<EUR_ISP_Error_Log__c> errors = new List<EUR_ISP_Error_Log__c>();
	private static Map<String, Id> RECORD_TYPES = EUR_ISP_Utils.getRecordTypesMap();
	private static Id recordTypeId = null;
	static
	{
		recordTypeId = RECORD_TYPES.get(EUR_ISP_Utils.EUR_ISP_ERROR_LOG_API_NAME + ERROR_LOG_RT_NAME);
	}

	/**
	 * check Database.SaveResult's and geneare Error message in case DML action faild
	 */
	public static void checkSaveResults(List<Database.SaveResult> saveResults)
	{
		for (Database.SaveResult saveResult : saveResults)
		{
			if (!saveResult.isSuccess())
			{
				String errMessage = '';
				for (Database.Error err : saveResult.getErrors())
				{
					errMessage += err.getMessage() + '\n\n';
				}
				addError(errMessage, 'Database:insert', null);
			}
		}
	}

	public static void setRecordTypeIdDE()
	{
		recordTypeId = RECORD_TYPES.get(EUR_ISP_Utils.EUR_ISP_ERROR_LOG_API_NAME + DE_ERROR_LOG_RT_NAME);
	}

	public static void setDefaultRecordTypeId()
	{
		recordTypeId = RECORD_TYPES.get(EUR_ISP_Utils.EUR_ISP_ERROR_LOG_API_NAME + ERROR_LOG_RT_NAME);
	}

	/**
	 * method to save error generated messages
	 */
	public static void commitErrors()
	{
		if (!errors.isEmpty())
		{
			Database.insert(errors, false);
		}
		errors.clear();
	}

	public static void clearErrors()
	{
		errors.clear();
	}

	/**
	 * generate and add new Error message to the list
	 */
	public static void addError(String message, String methodName, String recordId)
	{
		errors.add( generateRecord(message, methodName, recordId, TYPE_ERROR, recordTypeId) );
	}

	/**
	 * generate and add new Warning message to the list
	 */
	public static void addWarning(String message, String methodName, String recordId)
	{
		errors.add( generateRecord(message, methodName, recordId, TYPE_WARNING, recordTypeId) );
	}

	/**
	 * generate log record
	 */
	private static EUR_ISP_Error_Log__c generateRecord(String message, String methodName, String recordId, String type, Id rTypeId)
	{
		return new EUR_ISP_Error_Log__c(
		           RecordTypeId = rTypeId,
		           EUR_ISP_Error_Message__c = message,
		           EUR_ISP_Job_Name__c = methodName,
		           EUR_ISP_Record__c = recordId,
		           EUR_ISP_Type__c = type,
		           EUR_ISP_Status__c = STATUS_NEW
		       );
	}
}