/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
* Classe que armazena funções que podem ser re-aproveitadas por outros códigos. 
* NAME: Utils.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013 
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
global class Utils 
{
    
    static final String font1 = '{0} {1}' ;
    static final String font2 = '<b> {0} </b> {1}';
    static final String font3 = '<b><i> {0} </b></i> {1}';
    static final String beginTable = '<table cellspacing="2" width="100%"><font face="Lucida Console" size="10"><tr><td><b><center>' + System.Label.VF_VTS_00001_AR+ '</center></b></td><td><b><center>' + System.Label.VF_VTS_00002_AR+'</center></b></td> <td><b><center>' + System.Label.VF_VTS_00003_AR+ '</center></b></td></tr>';
    static final String beginTableWithDiscount = '<table cellspacing="2" width="100%"><font face="Lucida Console" size="10"><tr><td><b><center>' + System.Label.VF_VTS_00001_AR+ '</center></b></td><td><b><center>' + System.Label.VF_VTS_00004_AR+ '</center></b></td><td><b><center>' + System.Label.VF_VTS_00002_AR+'</center></b></td> <td><b><center>' + System.Label.VF_VTS_00003_AR+ '</center></b></td></tr>';
    static final String beginTableHeader = '<table cellspacing="2" width="100%"><font face="Lucida Console" size="10"><tr><td><b><center>' + System.Label.VF_VTS_00001_AR+ '</center></b></td> <td><b><center>' + System.Label.VF_VTS_00003_AR+ '</center></b></td></tr>';
    static final String endTable = '</font></table>';
    private static Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );


    private static Boolean isPartOfMobileCRMVar{get;set;}
    private static Boolean migrationDone{get;set;}

    
    private static String[] decodePriceComposition(String priceComposition, Boolean isHeader, Boolean includeDiscount){
    
        String[] res;
        String[] lines;
        Integer ind=0;
        
        lines = priceComposition.split('#',0);  
        
        res= new String[lines.size()];
        for(Integer i=0;i<lines.size();i++){
            res[i]=decodeLinePriceComposition(lines[i], isHeader, includeDiscount);
        }
        
        return res;
    
            
    }
    
    private static String decodeLinePriceComposition(String compositionLine, Boolean isHeader, Boolean includeDiscount){    
        
        String res = 'Formato Composição Preço Inválido (SOA/JDE).';
        String fontParm;
        String[] arguments = new String[2];
        String selFont = font1;        

        String[] line = compositionLine.split('\\|');
        if(line.size() != 5)
        { 
            return res;
        }
        else
        {
            fontParm = line[1];
            if (fontParm==null) selFont = '1';
            else if (fontParm.compareTo('2')==0 ) selFont = font2;
            else if (fontParm.compareTo('3')==0 ) selFont = font3;
            
            if (line!=null){
                if (includeDiscount) {
                    arguments[0] = '<tr><td width="250px"> '+line[0];
                    if(isHeader){
                        arguments[1] = ' </td> <td align="right" width="100px">' +formatNumber( line[4] ) + '</td> </tr>';
                    }
                    else{
                        arguments[1] = ' </td> <td align="right" width="120px">' +formatNumber( line[2] )+ '</td> <td align="right" width="120px">' +formatNumber( line[3] )+ '</td> <td align="right" width="120px">' +formatNumber( line[4] )+' </td></tr>';
                    }
                    res = String.format(selFont,arguments);
                } else {
                    arguments[0] = '<tr><td width="250px"> '+line[0];
                    if(isHeader){
                    arguments[1] = ' </td> <td align="right" width="100px">' +formatNumber( line[4] ) + '</td> </tr>';
                    }
                    else{
                        arguments[1] = ' </td>  <td align="right" width="120px">' +formatNumber( line[3] )+ '</td> <td align="right" width="120px">' +formatNumber( line[4] )+' </td></tr>';
                    }
                    res = String.format(selFont,arguments);
                }
            }
            return res;
        }
    }
    
    private static String formatNumber(String aValue){
        String returnValue;
        if(aValue.split(',').size()==2){
            Decimal decP =  Integer.ValueOf(aValue.split(',')[0]) > 0 ? Integer.ValueOf(aValue.split(',')[0])+0.1 : Integer.ValueOf(aValue.split(',')[0])-0.1;
            String resultStr = decP.format();
            resultStr = resultStr.subString(0, resultStr.length()-1);
            resultStr += aValue.split(',')[1];
            returnValue = resultStr;
        }else{
            returnValue = aValue;
        }
        return returnValue;
    }
    
    public static String decodeString( String aText, Boolean isHeader )
    {
        String[] priceComposition = decodePriceComposition( aText, isHeader, false);
        String lResponse = '';
        for ( String c : priceComposition ) {
          lResponse += c;
        }
        String strReturn;
        
        if ( isheader ) {
           strReturn = beginTableHeader + lResponse + endTable;
        } else {
           strReturn = beginTable + lResponse + endTable;
        }
        return strReturn;
    }
    
    public static Decimal getFlexAmount(String priceComponents) {
        List<String> lines = priceComponents.split('\\#');
        System.debug('%%%% lines : ' + lines);
        Decimal amountNBASE3, amountICMS, amountPIS, amountCOFINS = 0;
        for(String line : lines) {
            String[] splitted = line.split('\\|');
            System.debug('%%%%% line.split(\'|\') : '+splitted);
            if(splitted[0].equalsIgnoreCase('NBASE3')) {
                String formated = splitted[4];
                formated = formated.replaceFirst(',', '.');
                amountNBASE3 = Decimal.valueOf(formated);
            }
            if(splitted[0].equalsIgnoreCase('ICMS')) {
                String formated = splitted[4];
                formated = formated.replaceFirst(',', '.');
                amountICMS = Decimal.valueOf(formated);
            }
            if(splitted[0].equalsIgnoreCase('PIS')) {
                String formated = splitted[4];
                formated = formated.replaceFirst(',', '.');
                System.debug('%%%%% formated : ' + formated);
                amountPIS = Decimal.valueOf(formated);
            }
            if(splitted[0].equalsIgnoreCase('COFINS')) {
                String formated = splitted[4];
                formated = formated.replaceFirst(',', '.');
                amountCOFINS = Decimal.valueOf(formated);
            }
        }
        System.debug('%%%% NBASE3 : ' + amountNBASE3 +' || ICMS : ' + amountICMS +' || PIS : ' + amountPIS +' COFIN : ' + amountCOFINS);
        Decimal amountNis = amountNBASE3 - amountICMS - amountPIS - amountCOFINS;
        return amountNis;
    } 

    public static Decimal getFlexEdiDiscount(String priceComponents) {
        List<String> lines = priceComponents.split('\\#');
        System.debug('%%%% lines : ' + lines);
        Decimal precioBase = 0;
        Decimal descuentoFlex = 1;
        for(String line : lines) {
            String[] splitted = line.split('\\|');
            System.debug('%%%%% line.split(\'|\') : '+splitted);
            if(splitted[0].equalsIgnoreCase('Preço Base')) {
                String formated = splitted[4];
                formated = formated.replaceFirst(',', '.');
                precioBase = Decimal.valueOf(formated);
            }
            if(splitted[0].equalsIgnoreCase('Flex')) {
                String formated = splitted[4];
                formated = formated.replaceFirst(',', '.');
                descuentoFlex = Decimal.valueOf(formated);
            }
        }
        System.debug('%%%% precioBase : ' + precioBase +' || descuentoFlex : ' + descuentoFlex);
        if(precioBase != null && precioBase != 0 && descuentoFlex != null){
            Decimal retorno = (descuentoFlex / precioBase) * 100;
            System.debug('%%%%% retorno FlexEdiDiscount : ' + retorno);
            return  retorno;
        }
        
        return 0;
    } 

    public static String decodeStringWithDiscount( String aText, Boolean isHeader )
    {
        String[] priceComposition = decodePriceComposition( aText, isHeader, true);
        String lResponse = '';
        for ( String c : priceComposition ) {
          lResponse += c;
        }
        if ( isheader ) {
          return beginTableHeader + lResponse + endTable;
        } else {
          return beginTableWithDiscount + lResponse + endTable;
        }
    }
    
    public static String getCodeFromUDC(Id idUDCSalesforce)
    {
    
        String retUdc = '';
        if (idUDCSalesforce==null) return retUdc;
          List< UDC__c > udc = [ SELECT CodDefUsuario__c FROM UDC__c WHERE Id=:idUDCSalesforce
              AND RecordTypeId =: idRecTypeUdc ];
          if (udc.size()>0) return udc[0].CodDefUsuario__c;
          else return retUdc;
    
    }
    
    public static String getNameFromUDC(Id idUDCSalesforce)
    {
    
        String retUdc = '';
        if (idUDCSalesforce==null) return retUdc;
          List< UDC__c > udc = [ SELECT Name FROM UDC__c WHERE Id=:idUDCSalesforce
               AND RecordTypeId =: idRecTypeUdc];
          if (udc.size()>0) return udc[0].Name;
          else return retUdc;
    }
  
  public static Id getIDFromUDC( String aCodDefUser, String aCodProd, String aCodUs )
  {
  
    String lIntId = aCodDefUser + aCodProd + aCodUs;
    List< UDC__c > udc = [select id from UDC__c where Internal_id__c =:lIntId ];
    if (udc.size() > 0 ) return udc[ 0 ].id;
    else return null;
  
  }  
  
  public static String getUserNameSplit( String aUserName ){
  
    List< String > lListStr = aUserName.split('@');
    return lListStr[0];
   
  }

     public static boolean isPartOfMobileCRM(string userID){
        if(isPartOfMobileCRMVar == null){
            boolean retorno = false;
            string groupName = 'LAT_BR_Vendas_Restringido';
            List<Group> lstGroup = [select id from group where name =:groupName ];
            if(lstGroup != null && lstGroup.size() > 0){
                Group theGroup = lstGroup[0];
                user theUser = [select id, name from User where id=:userId][0];
                list<groupMember> grMembers = [select ID from groupMember where groupId=:theGroup.id and userOrGroupID =:userID];
                if(grMembers.size()>0){
                    retorno = true;
                    
                }
                system.debug('===================' + retorno);
            }
            isPartOfMobileCRMVar = retorno;
        }        
        return isPartOfMobileCRMVar;
    }


    public static boolean wasMigrationDone(string countryCode){ 
        if(migrationDone == null){
            boolean retorno = false;

            List <String> migratedCountries = LAT_GeneralConfigDao.getValueAsStringArray('MIGRATION_COUNTRIES',';');

            Map<String, Boolean> migrationMaps = new Map<String, Boolean>();
            if(migratedCountries != null){
                for (String s: migratedCountries) {
                    String[] country = s.split(':');
                    if (country != null && country.size() > 1) {
                        migrationMaps.put(country[0], Boolean.valueOf(country[1]));
                    }
                }
                if(migrationMaps.get(countryCode) != null){
                    retorno = migrationMaps.get(countryCode);
                }
            }

            migrationDone = retorno;
        }        
        return migrationDone;
    }

    public static boolean wasMigrationDoneByRecords(List<string> objIds){ 
        Set<String> oldObjects = new Set<String>{'006', '00k', '01t', '500' ,'501'};
        if(objIds != null && objIds.size() > 0){
            if(oldObjects.contains(objIds[0].substring(0,3))){
                return false;
            }
        }
        return true;
    }


    webservice static String isMobileUser(String userId){
    
        String error = '';
        
        if(isPartOfMobileCRM(userId)){
            error = Label.LAT_BR_BTN_User_CRM_Mobile;
        }
        
        return error;     
    }
     //Flag for migration
    public static void insertMigrationCustomSetting(String pais, String estado) {
    
        String valueConfig = pais + ':' + estado;

        system.debug('NicoBan' + valueConfig);
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
             Name = 'MIGRATION_COUNTRIES',
             LAT_Value__c = valueConfig);
        insert cfg;
    }

    public static void setMigrationDoneTest(Boolean b){
        migrationDone = b;
    }
    
    public static boolean isPartOfGroup(string groupName){
        boolean retorno = false;
        
        List<Group> lstGroup = [select id from group where name =:groupName];
        
        if(lstGroup != null && lstGroup.size() > 0){
            Group theGroup = lstGroup[0];
           // user theUser = [select id, name from User where id=:UserInfo.getUserID][0];
            list<groupMember> grMembers = [select ID from groupMember where groupId = :theGroup.id and userOrGroupID = :UserInfo.getUserID()];
            
            if(grMembers.size()>0){
                retorno = true;
                
            }
        }
        
    return retorno;
        
    }
}