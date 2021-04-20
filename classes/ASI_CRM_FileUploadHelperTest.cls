@isTest
public class ASI_CRM_FileUploadHelperTest {

	@isTest
	static void testGetFileExtension() {
		System.assertEquals('txt', ASI_CRM_FileUploadHelper.getFileExtension('file.txt'));
	}

	@isTest
	static void testGetCsvDataWithEncoding() {
		String content = '"INV","U","123","customer","20170701","test1","135183","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
            			+'"INV","U","123","customer","20170701","test1","135184","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","135185","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","135186","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","135187","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","135188","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","PRS-AAT-18-0065","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF;

		final List<List<String>> csvData = ASI_CRM_FileUploadHelper.getCsvData(EncodingUtil.base64Encode(Blob.valueOf(content)), true);
	}

    @isTest
	static void testGetCsvDataWithoutEncoding() {
		String content = '"INV","U","123","customer","20170701","test1","135183","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
            			+'"INV","U","123","customer","20170701","test1","135184","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","135185","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","135186","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","135187","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","135188","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF
                		+'"INV","U","123","customer","20170701","test1","PRS-AAT-18-0065","3","","","",""'+ASI_CRM_CSVReaderHelper.CRLF;

		final List<List<String>> csvData = ASI_CRM_FileUploadHelper.getCsvData(content, false);
	}
    
	@isTest
	static void testRemoveCsvHeader() {

		final List<List<String>> rows = new List<List<String>>();
		rows.add(new List<String> {'Name', 'Contact'});
		rows.add(new List<String> {'User1', '123123'});

		System.assertEquals(2, rows.size());

		ASI_CRM_FileUploadHelper.removeCsvHeader(rows);

		System.assertEquals(1, rows.size());

		System.assertEquals(false, ASI_CRM_FileUploadHelper.removeCsvHeader(new List<List<String>>()));
	}

	@isTest
	static void testGetColumnValuesSetFromCsvData() {

		final List<List<String>> rows = new List<List<String>>();
		rows.add(new List<String> {'Name', 'Contact'});
		rows.add(new List<String> {'User1', '123123'});

		final List<String> dataList = ASI_CRM_FileUploadHelper.getColumnValueListFromCSVData(rows, 0);
		System.assertEquals(rows.size(), dataList.size());
		System.assertEquals(rows.get(0).get(0), dataList.get(0));
	}

	@isTest
	static void testAddCsvColumn() {

		final List<List<String>> rows = new List<List<String>>();
		rows.add(new List<String> {'Name', 'Contact'});
		rows.add(new List<String> {'User1', '123123'});
		ASI_CRM_FileUploadHelper.addCsvColumn(rows.get(0), 'columnValue');

		System.assertEquals(rows.get(0).size(), rows.get(1).size() + 1);
	}
}