/**********************************************************************************
 * Name : ASI_CRM_JP_AsciiToHexConverter
 * Created : DC @03/14/2016 10:22 AM
 * Revision History:
 * 1. 03/14/2016 - [DC 1.0] Created
 **********************************************************************************/

public with sharing class ASI_CRM_JP_AsciiToHexConverter {
    
    public static final String ERROR_STRING = 'EMPTY_STRING_ERROR';

    // Varibles necessary for conversion
    private List<Integer> inputStringIntValues;
    private List<String> convertedHexValues;
    private Decimal decimalValue;
    private Integer hexValueLength = 4; // Converter needs the hex values with 4 characters length
    private Integer inputBase = 10;
    private Integer outputBase = 16;
    private String outputValue = ''; 
    private String numericBaseData = '0123456789ABCDEF';
    private Integer indexHolder;
    private Integer maxBase = numericBaseData.length();

    public ASI_CRM_JP_AsciiToHexConverter(String pInputString) {

        pInputString = String.isBlank(pInputString) ? '' : pInputString;
        inputStringIntValues = pInputString.getChars();
        decimalValue = 0.0;

    }

    public List<String> convert() {

        convertedHexValues = new List<String>();

        for(Integer intValue : inputStringIntValues) {

            outputValue = '';
            decimalValue = intValue;

            if(decimalValue > 0) {
                while(decimalValue > 0) {

                      indexHolder = (Integer) (((decimalValue / outputBase) - (Integer) (decimalValue / outputBase)) * outputBase + 1.5);
                      System.debug('indexHolder' + indexHolder);
                      outputValue = numericBaseData.subString(indexHolder - 1, indexHolder) + outputValue;
                      decimalValue = Integer.valueOf(decimalValue / outputBase);

                }
                System.debug('outputValue =: ' + outputValue);

                // To Ensure that all Hex codes generated have length = 4.
                while(outputValue.length() < hexValueLength) {
                    outputValue = '0' + outputValue;
                }

                convertedHexValues.add(outputValue);
            }
        }

        if(convertedHexValues.isEmpty()) {
            convertedHexValues = new List<String> {
                ERROR_STRING
            };
        }

        return convertedHexValues;
    }
}

/*

*/