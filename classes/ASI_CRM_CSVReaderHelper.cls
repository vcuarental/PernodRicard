public class ASI_CRM_CSVReaderHelper {
    public static final String COMMA = String.fromCharArray(new List<Integer>{
            44
    });
    public static final String CR = '\r';
    public static final String DQUOTE = '\"';
    public static final String QUOTE = '\'';
    public static final String LF = '\n';
    public static final String CRLF = CR + LF;
    public static final String LFCR = LF + CR;
    public static final String DQUOTEDQUOTE = DQUOTE + DQUOTE;
    public static final String MESSAGE_INVALID_CSV_ROW = 'Invalid CSV Row';

    public static List<List<String>> readCSVString(String fileString) {

        if (!fileString.endsWith(CRLF)) {
            fileString = fileString + CRLF;
        }

        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CSVValue csvValue = new CSVValue();

        Boolean eod = false;
        while (!eod) {
            csvValue = readCSVValues(fileString);
            rowValues.add(csvValue.value);

            if (csvValue.delimiter == CRLF) {
                fileValues.add(rowValues);

                if (fileValues.size() > 0) {
                    if (fileValues.get(0).size() != rowValues.size()) {
                        throw new ASI_CRM_CommonRoutine.CustomException(MESSAGE_INVALID_CSV_ROW);
                    }
//                    System.assertEquals(fileValues.get(0).size(), rowValues.size(), MESSAGE_INVALID_CSV_ROW);
                }

                rowValues = new List<String>();
            }

            if (csvValue.biteSize() == fileString.length()) {
                eod = true;
            } else {
                fileString = fileString.substring(csvValue.biteSize());
            }
        }

        return fileValues;
    }

    public static CSVValue readCSVValues(String data) {
//        System.assert(data.endsWith(CRLF), MESSAGE_INVALID_CSV_ROW);
        if (!data.endsWith(CRLF)) {
            throw new ASI_CRM_CommonRoutine.CustomException(MESSAGE_INVALID_CSV_ROW);
        }

        CSVValue csvValue = new CSVValue();

        if (data.startsWith(DQUOTE)) {
            csvValue.enclosed = true;

            Integer searchIndex = 1;      // starting index to search
            Integer dquoteIndex = -1;     // index of DQUOTE
            Integer dquotesIndex = -1;    // index of DQUOTEDQUOTE

            Boolean closerFound = false;

            while (!closerFound) {
                dquoteIndex = data.indexOf(DQUOTE, searchIndex);
                dquotesIndex = data.indexOf(DQUOTEDQUOTE, searchIndex);

                System.assert(dquoteIndex != -1);

                if (dquoteIndex == dquotesIndex) {
                    searchIndex = dquotesIndex + DQUOTEDQUOTE.length();
                } else {
                    closerFound = true;
                }
            }

            csvValue.value = data.substring(DQUOTE.length(), dquoteIndex).replaceAll(DQUOTEDQUOTE, DQUOTE);

            Integer commaIndex = data.indexOf(COMMA, dquoteIndex);
            Integer crlfIndex = data.indexOf(CRLF, dquoteIndex);

            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.delimiter = COMMA;
            } else {
                csvValue.delimiter = CRLF;
            }
        } else {
            csvValue.enclosed = false;

            Integer commaIndex = data.indexOf(COMMA);
            Integer crlfIndex = data.indexOf(CRLF);

            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.value = data.substring(0, commaIndex);
                csvValue.delimiter = COMMA;
            } else {
                csvValue.value = data.substring(0, crlfIndex);
                csvValue.delimiter = CRLF;
            }
        }

        return csvValue;
    }

    public static Blob createCSVFile(List<List<String>> data, string header) {
        String csvString = '';
		csvString += header;
        for(List<String> row : data) {
            for (String column : row) {
                csvString += column + COMMA;
            }
            csvString += CRLF;
        }
        return Blob.valueOf(csvString);
    }

    private class CSVValue {
        public String value;
        public Boolean enclosed;
        public String delimiter;

        public CSVValue() {
            this(null, null, null);
        }

        public CSVValue(String value, Boolean enclosed, String delimiter) {
            this.value = value;
            this.enclosed = enclosed;
            this.delimiter = delimiter;
        }

        public Integer biteSize() {
            Integer biteSize = value.replaceAll(DQUOTE, DQUOTEDQUOTE).length() + delimiter.length();

            if (enclosed) {
                biteSize += DQUOTE.length() * 2;
            }

            return biteSize;
        }
    }
}