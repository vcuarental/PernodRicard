/**********************************************************************************
 * Name : ASI_CRM_JP_FullWidthToHalfWidth
 * Created : DC @02/18/2016 12:17 PM
 * Revision History:
 * 1. 02/18/2016 - [DC 1.0] Created
 **********************************************************************************/

public with sharing class ASI_CRM_JP_FullWidthToHalfWidth {
    
    /* Instance */
    private static final ASI_CRM_JP_FullWidthToHalfWidth instance
        = new ASI_CRM_JP_FullWidthToHalfWidth();

    /* Hexadecimal to Decimal replacement Map */
    private Map<String, Integer> hexadecimalToDecimalMap;

    /* Full-width Kana substitution Map */
    private Map<String, String> replaceMap;

    /* Full-width Kana substitution Map Unicode */
    private Map<String, String> replaceHexadecimalMap;

    /**
     * Constructor
     */
    public ASI_CRM_JP_FullWidthToHalfWidth() {
        
        // Hexadecimal to Decimal conversion map
        hexadecimalToDecimalMap = new Map<String, Integer>();
        
        hexadecimalToDecimalMap.put('0', 0);
        hexadecimalToDecimalMap.put('1', 1);
        hexadecimalToDecimalMap.put('2', 2);
        hexadecimalToDecimalMap.put('3', 3);
        hexadecimalToDecimalMap.put('4', 4);
        hexadecimalToDecimalMap.put('5', 5);
        hexadecimalToDecimalMap.put('6', 6);
        hexadecimalToDecimalMap.put('7', 7);
        hexadecimalToDecimalMap.put('8', 8);
        hexadecimalToDecimalMap.put('9', 9);
        hexadecimalToDecimalMap.put('A', 10);
        hexadecimalToDecimalMap.put('B', 11);
        hexadecimalToDecimalMap.put('C', 12);
        hexadecimalToDecimalMap.put('D', 13);
        hexadecimalToDecimalMap.put('E', 14);
        hexadecimalToDecimalMap.put('F', 15);

        // Half-width Kana substitution Map created
        replaceHexadecimalMap = new Map<String, String>();
        
        // Punctuation Marks
        replaceHexadecimalMap.put('FF01','0021');
        replaceHexadecimalMap.put('FF02','0022');
        replaceHexadecimalMap.put('FF03','0023');
        replaceHexadecimalMap.put('FF04','0024');
        replaceHexadecimalMap.put('FF05','0025');
        replaceHexadecimalMap.put('FF06','0026');
        replaceHexadecimalMap.put('FF07','0027');
        replaceHexadecimalMap.put('FF08','0028');
        replaceHexadecimalMap.put('FF09','0029');
        replaceHexadecimalMap.put('FF0A','002A');
        replaceHexadecimalMap.put('FF0B','002B');
        replaceHexadecimalMap.put('FF0C','002C');
        replaceHexadecimalMap.put('FF0D','002D');
        replaceHexadecimalMap.put('FF0E','002E');
        replaceHexadecimalMap.put('FF0F','002F');
        replaceHexadecimalMap.put('FF10','0030');
        replaceHexadecimalMap.put('FF11','0031');
        replaceHexadecimalMap.put('FF12','0032');
        replaceHexadecimalMap.put('FF13','0033');
        replaceHexadecimalMap.put('FF14','0034');
        replaceHexadecimalMap.put('FF15','0035');
        replaceHexadecimalMap.put('FF16','0036');
        replaceHexadecimalMap.put('FF17','0037');
        replaceHexadecimalMap.put('FF18','0038');
        replaceHexadecimalMap.put('FF19','0039');
        replaceHexadecimalMap.put('FF1A','003A');
        replaceHexadecimalMap.put('FF1B','003B');
        replaceHexadecimalMap.put('FF1C','003C');
        replaceHexadecimalMap.put('FF1D','003D');
        replaceHexadecimalMap.put('FF1E','003E');
        replaceHexadecimalMap.put('FF1F','003F');
        replaceHexadecimalMap.put('FF20','0040');

        // Capital Latin Characters (A-Z)
        replaceHexadecimalMap.put('FF21','0041');
        replaceHexadecimalMap.put('FF22','0042');
        replaceHexadecimalMap.put('FF23','0043');
        replaceHexadecimalMap.put('FF24','0044');
        replaceHexadecimalMap.put('FF25','0045');
        replaceHexadecimalMap.put('FF26','0046');
        replaceHexadecimalMap.put('FF27','0047');
        replaceHexadecimalMap.put('FF28','0048');
        replaceHexadecimalMap.put('FF29','0049');
        replaceHexadecimalMap.put('FF2A','004A');
        replaceHexadecimalMap.put('FF2B','004B');
        replaceHexadecimalMap.put('FF2C','004C');
        replaceHexadecimalMap.put('FF2D','004D');
        replaceHexadecimalMap.put('FF2E','004E');
        replaceHexadecimalMap.put('FF2F','004F');
        replaceHexadecimalMap.put('FF30','0050');
        replaceHexadecimalMap.put('FF31','0051');
        replaceHexadecimalMap.put('FF32','0052');
        replaceHexadecimalMap.put('FF33','0053');
        replaceHexadecimalMap.put('FF34','0054');
        replaceHexadecimalMap.put('FF35','0055');
        replaceHexadecimalMap.put('FF36','0056');
        replaceHexadecimalMap.put('FF37','0057');
        replaceHexadecimalMap.put('FF38','0058');
        replaceHexadecimalMap.put('FF39','0059');
        replaceHexadecimalMap.put('FF3A','005A');

        // Punctuation Marks
        replaceHexadecimalMap.put('FF3B','005B');
        replaceHexadecimalMap.put('FF3C','005C');
        replaceHexadecimalMap.put('FF3D','005D');
        replaceHexadecimalMap.put('FF3E','005E');
        replaceHexadecimalMap.put('FF3F','005F');
        replaceHexadecimalMap.put('FF40','0060');

        // Small Latin Characters (a-z)
        replaceHexadecimalMap.put('FF41','0061');
        replaceHexadecimalMap.put('FF42','0062');
        replaceHexadecimalMap.put('FF43','0063');
        replaceHexadecimalMap.put('FF44','0064');
        replaceHexadecimalMap.put('FF45','0065');
        replaceHexadecimalMap.put('FF46','0066');
        replaceHexadecimalMap.put('FF47','0067');
        replaceHexadecimalMap.put('FF48','0068');
        replaceHexadecimalMap.put('FF49','0069');
        replaceHexadecimalMap.put('FF4A','006A');
        replaceHexadecimalMap.put('FF4B','006B');
        replaceHexadecimalMap.put('FF4C','006C');
        replaceHexadecimalMap.put('FF4D','006D');
        replaceHexadecimalMap.put('FF4E','006E');
        replaceHexadecimalMap.put('FF4F','006F');
        replaceHexadecimalMap.put('FF50','0070');
        replaceHexadecimalMap.put('FF51','0071');
        replaceHexadecimalMap.put('FF52','0072');
        replaceHexadecimalMap.put('FF53','0073');
        replaceHexadecimalMap.put('FF54','0074');
        replaceHexadecimalMap.put('FF55','0075');
        replaceHexadecimalMap.put('FF56','0076');
        replaceHexadecimalMap.put('FF57','0077');
        replaceHexadecimalMap.put('FF58','0078');
        replaceHexadecimalMap.put('FF59','0079');
        replaceHexadecimalMap.put('FF5A','007A');

        // Punctuation Marks
        replaceHexadecimalMap.put('FF5B','007B');
        replaceHexadecimalMap.put('FF5C','007C');
        replaceHexadecimalMap.put('FF5D','007D');
        replaceHexadecimalMap.put('FF5E','007E');
        replaceHexadecimalMap.put('FF5F','2985');
        replaceHexadecimalMap.put('FF60','2986');
        replaceHexadecimalMap.put('FF61','3002');
        replaceHexadecimalMap.put('FF62','FF62');
        replaceHexadecimalMap.put('FF63','FF63');
        replaceHexadecimalMap.put('FF64','FF64');

        /**
         *  <<<DELIMITER>>> // All delimiters are added by DC for developer reference only.
         */

        // Special Symbols
        replaceHexadecimalMap.put('FFE0','00A2');
        replaceHexadecimalMap.put('FFE1','00A3');
        replaceHexadecimalMap.put('FFE2','00AC');
        replaceHexadecimalMap.put('FFE3','00AF');
        replaceHexadecimalMap.put('FFE4','00A6');
        replaceHexadecimalMap.put('FFE5','00A5');
        replaceHexadecimalMap.put('FFE6','20A9');

        /**
         *  <<<DELIMITER>>>
         */

        // Special Symbols
        replaceHexadecimalMap.put('FFE8','2502');
        replaceHexadecimalMap.put('FFE9','2190');
        replaceHexadecimalMap.put('FFEA','2191');
        replaceHexadecimalMap.put('FFEB','2192');
        replaceHexadecimalMap.put('FFEC','2193');
        replaceHexadecimalMap.put('FFED','25A0');
        replaceHexadecimalMap.put('FFEE','25CB');
        
        //Space
        replaceHexadecimalMap.put('3000','0020');
        replaceHexadecimalMap.put('2001','0020');
        replaceHexadecimalMap.put('2003','0020');
        /**
         *  <<<DELIMITER>>>
         */

        // Japanese Characters
        replaceHexadecimalMap.put('30A1','FF67');
        replaceHexadecimalMap.put('30A2','FF71');
        replaceHexadecimalMap.put('30A3','FF68');
        replaceHexadecimalMap.put('30A4','FF72');
        replaceHexadecimalMap.put('30A5','FF69');
        replaceHexadecimalMap.put('30A6','FF73');
        replaceHexadecimalMap.put('30A7','FF6A');
        replaceHexadecimalMap.put('30A8','FF74');
        replaceHexadecimalMap.put('30A9','FF6B');
        replaceHexadecimalMap.put('30AA','FF75');
        replaceHexadecimalMap.put('30AB','FF76');
        replaceHexadecimalMap.put('30AC','FF76,FF9E');
        replaceHexadecimalMap.put('30AD','FF77');
        replaceHexadecimalMap.put('30AE','FF77,FF9E');
        replaceHexadecimalMap.put('30AF','FF78');

        replaceHexadecimalMap.put('30B0','FF78,FF9E');
        replaceHexadecimalMap.put('30B1','FF79');
        replaceHexadecimalMap.put('30B2','FF79,FF9E');
        replaceHexadecimalMap.put('30B3','FF7A');
        replaceHexadecimalMap.put('30B4','FF7A,FF9E');
        replaceHexadecimalMap.put('30B5','FF7B');
        replaceHexadecimalMap.put('30B6','FF7B,FF9E');
        replaceHexadecimalMap.put('30B7','FF7C');
        replaceHexadecimalMap.put('30B8','FF7C,FF9E');
        replaceHexadecimalMap.put('30B9','FF7D');
        replaceHexadecimalMap.put('30BA','FF7D,FF9E');
        replaceHexadecimalMap.put('30BB','FF7E');
        replaceHexadecimalMap.put('30BC','FF7E,FF9E');
        replaceHexadecimalMap.put('30BD','FF7F');
        replaceHexadecimalMap.put('30BE','FF7F,FF9E');
        replaceHexadecimalMap.put('30BF','FF80');

        replaceHexadecimalMap.put('30C0','FF80,FF9E');
        replaceHexadecimalMap.put('30C1','FF81');
        replaceHexadecimalMap.put('30C2','FF81,FF9E');
        replaceHexadecimalMap.put('30C3','FF6F');
        replaceHexadecimalMap.put('30C4','FF82');
        replaceHexadecimalMap.put('30C5','FF82,FF9E');
        replaceHexadecimalMap.put('30C6','FF83');
        replaceHexadecimalMap.put('30C7','FF83,FF9E');
        replaceHexadecimalMap.put('30C8','FF84');
        replaceHexadecimalMap.put('30C9','FF84,FF9E');
        replaceHexadecimalMap.put('30CA','FF85');
        replaceHexadecimalMap.put('30CB','FF86');
        replaceHexadecimalMap.put('30CC','FF87');
        replaceHexadecimalMap.put('30CD','FF88');
        replaceHexadecimalMap.put('30CE','FF89');
        replaceHexadecimalMap.put('30CF','FF8A');

        replaceHexadecimalMap.put('30D0','FF8A,FF9E');
        replaceHexadecimalMap.put('30D1','FF8A,FF9F');
        replaceHexadecimalMap.put('30D2','FF8B');
        replaceHexadecimalMap.put('30D3','FF8B,FF9E');
        replaceHexadecimalMap.put('30D4','FF8B,FF9F');
        replaceHexadecimalMap.put('30D5','FF8C');
        replaceHexadecimalMap.put('30D6','FF8C,FF9E');
        replaceHexadecimalMap.put('30D7','FF8C,FF9F');
        replaceHexadecimalMap.put('30D8','FF8D');
        replaceHexadecimalMap.put('30D9','FF8D,FF9E');
        replaceHexadecimalMap.put('30DA','FF8D,FF9F');
        replaceHexadecimalMap.put('30DB','FF8E');
        replaceHexadecimalMap.put('30DC','FF8E,FF9E');
        replaceHexadecimalMap.put('30DD','FF8E,FF9F');
        replaceHexadecimalMap.put('30DE','FF8F');
        replaceHexadecimalMap.put('30DF','FF90');

        replaceHexadecimalMap.put('30E0','FF91');
        replaceHexadecimalMap.put('30E1','FF92');
        replaceHexadecimalMap.put('30E2','FF93');
        replaceHexadecimalMap.put('30E3','FF6C');
        replaceHexadecimalMap.put('30E4','FF94');
        replaceHexadecimalMap.put('30E5','FF6D');
        replaceHexadecimalMap.put('30E6','FF95');
        replaceHexadecimalMap.put('30E7','FF6E');
        replaceHexadecimalMap.put('30E8','FF96');
        replaceHexadecimalMap.put('30E9','FF97');
        replaceHexadecimalMap.put('30EA','FF98');
        replaceHexadecimalMap.put('30EB','FF99');
        replaceHexadecimalMap.put('30EC','FF9A');
        replaceHexadecimalMap.put('30ED','FF9B');
        // replaceHexadecimalMap.put('30EE','Waiting for value');
        replaceHexadecimalMap.put('30EF','FF9C');

        // replaceHexadecimalMap.put('30F0','Waiting for value');
        // replaceHexadecimalMap.put('30F1','Waiting for value');
        // replaceHexadecimalMap.put('30F2','Waiting for value');
        replaceHexadecimalMap.put('30F3','FF9D');
        replaceHexadecimalMap.put('30F4','FF73,FF9E');
        // replaceHexadecimalMap.put('30F5','Waiting for value');
        // replaceHexadecimalMap.put('30F6','Waiting for value');
        replaceHexadecimalMap.put('30F7','FF9C,FF9E');
        // replaceHexadecimalMap.put('30F8','FF96');
        // replaceHexadecimalMap.put('30F9','FF97');
        // replaceHexadecimalMap.put('30FA','FF98');
        replaceHexadecimalMap.put('30FB','FF65');
        replaceHexadecimalMap.put('30FC','FF70');

        replaceMap = new Map<String, String>();
        
        for(String key : replaceHexadecimalMap.keySet()) {
            replaceMap.put(unicodeToString(key.split(',', 0)), unicodeToString(replaceHexadecimalMap.get(key).split(',', 0)));
        }
    }

    /**
     * Convert the Unicode to string
     * @param unicodes unicode
     * @return Text columns
     */
    public String unicodeToString(String[] pUnicodes) {
        List<Integer> stringCharacters = new List<Integer>();
        for(String unicode : pUnicodes) {
            Integer singleCharacter = 0;
            for(Double i=0, len=unicode.length(); i<len; i++) {
                singleCharacter += (Math.pow(16, (len - i - 1)).intValue() * hexadecimalToDecimalMap.get(unicode.substring(i.intValue(), i.intValue()+1)));
            }
            stringCharacters.add(singleCharacter);
        }
        return String.fromCharArray(stringCharacters);
    }

    /**
     * Determines whether the replacement is necessary
     * @param pInputString character string
     * @return true/false
     */
    public Boolean isReplace(String pInputString) {
        if(!Pattern.matches('^[^\\uFF01-\\uFF64]{1,}$', pInputString)) {
            return false;
        }
        if(!Pattern.matches('^[^\\uFFE0-\\uFFE6]{1,}$', pInputString)) {
            return false;
        }
        if(!Pattern.matches('^[^\\uFFE8-\\uFFEE]{1,}$', pInputString)) {
            return false;
        }
        if(!Pattern.matches('^[^\\u30A1-\\u30FC]{1,}$', pInputString)) {
            return false;
        }
        return true;
    }

    /**
     * Replacement
     * @param pInputString character string
     * @return The replacement string
     */
    public String replace(String pInputString) {
        if(String.isBlank(pInputString)) {
            return pInputString;
        }

        // Half-width Kana
        if(isReplace(pInputString)) {
            return pInputString;
        }

        for(String key : replaceMap.keySet()) {
            pInputString = pInputString.replaceAll(key, Matcher.quoteReplacement(replaceMap.get(key)));
        }

        return pInputString;
    }

    /**
     * Instance acquisition
     * return Instance
     */
    public static ASI_CRM_JP_FullWidthToHalfWidth getInstance() {
        return ASI_CRM_JP_FullWidthToHalfWidth.instance;
    }
}



/*
FOR SAMPLE EXECUTION:

// Instance acquisition 
ASI_CRM_JP_FullWidthToHalfWidth converter = ASI_CRM_JP_FullWidthToHalfWidth.GetInstance (); 

String [] Codes = new String [] { '30EB', 'FF21'}; 
String str = converter.UnicodeToString(Codes); 

// replacement 
String restr = converter.replace (str);
System.debug(' ------ str------ : ' + str);
System.debug(' ------ restr ------ : ' + restr );

System.debug(' ------ str.getChars() ------ : ' + str.getChars());
System.debug(' ------ restr.getChars() ------ : ' + restr.getChars());
*/