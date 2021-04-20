public with sharing class ASI_CRM_FileUploadHelper {

	public enum FileExtension {
			csv, txt, jpg, jpeg, png
	}

	public static final Integer MAX_FILE_SIZE = 5242880;

	public static String getFileExtension(String filename) {
		final List<String> filenameSubString = filename.split('\\.');

		if (filenameSubString.isEmpty()) return '';

		return filenameSubString.get(filenameSubString.size() - 1).toLowerCase();
	}

	public static List<List<String>> getCsvData(String data, Boolean decode) {

		if(decode) {
			String base64Data = EncodingUtil.urlDecode(data, 'UTF-8');
			String rawCsvData = EncodingUtil.base64Decode(base64Data).toString();
			return ASI_CRM_CSVReaderHelper.readCSVString(rawCsvData);
		}

		try {
            System.debug('-ASI_CRM_CSVReaderHelper.readCSVString-'+ASI_CRM_CSVReaderHelper.readCSVString(data));
			return ASI_CRM_CSVReaderHelper.readCSVString(data);
		} catch (Exception e) {
			System.debug(e);
			return null;
		}
	}

	public static Boolean removeCsvHeader(List<List<String>> csvData) {
		try {
			csvData.remove(0);
			return true;
		} catch (Exception e) {
			System.debug(e);
			return false;
		}
	}

	public static List<String> getColumnValueListFromCSVData(List<List<String>> csvData, Integer columnIndex) {
		final List<String> columnDataList = new List<String>();

		for (List<String> row : csvData) {
			columnDataList.add(row.get(columnIndex));
		}

		return columnDataList;
	}

	public static Set<String> getColumnValueSetFromCSVData(List<List<String>> csvData, Integer columnIndex) {
		final List<String> columnDataList = getColumnValueListFromCSVData(csvData, columnIndex);
		return new Set<String>(columnDataList);
	}

	public static void addCsvColumn(List<String> csvRow, String messageString) {
		csvRow.add(messageString);
	}

}