@isTest
private class ASI_CRM_CSVReaderHelperTest {

	@isTest
	static void testReadCsvString() {

		String csvString = 'Sno,Name' + ASI_CRM_CSVReaderHelper.CRLF;
		csvString += '1,Test1' + ASI_CRM_CSVReaderHelper.CRLF;

		final List<List<String>> csvData = ASI_CRM_CSVReaderHelper.readCSVString(csvString);

		System.assert(csvData.size() == 2);

	}

	@isTest
	static void testReadCsvString_ValuesWithQuotes() {

		String csvString = 'Sno,Name' + ASI_CRM_CSVReaderHelper.CRLF;
		csvString += '1,"Test1"' + ASI_CRM_CSVReaderHelper.CRLF;

		final List<List<String>> csvData = ASI_CRM_CSVReaderHelper.readCSVString(csvString);

		System.assert(csvData.size() == 2);

	}

	@isTest
	static void testReadCsvString_InconsistentColumns() {

		String csvString = 'Sno,Name' + ASI_CRM_CSVReaderHelper.CRLF;
		csvString += '1,Test1' + ASI_CRM_CSVReaderHelper.CRLF;
		csvString += '2' + ASI_CRM_CSVReaderHelper.CRLF;

		try {
		final List<List<String>> csvData = ASI_CRM_CSVReaderHelper.readCSVString(csvString);
		} catch (Exception e) {
			System.assert(e.getTypeName().contains('CustomException'));
		}

	}

	@isTest
	static void testCreateCSVFile() {

		final List<List<String>> data = new List<List<String>>();
		data.add(new List<String>{'1', 'Name1'});
		data.add(new List<String>{'2', 'Name2'});

		final String header = 'Sno,Name';

		final Blob result = ASI_CRM_CSVReaderHelper.createCSVFile(data, header);

		System.assert(result != null);
	}

}