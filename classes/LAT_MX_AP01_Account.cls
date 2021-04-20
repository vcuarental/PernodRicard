/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Account
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_MX_AP01_Account {

  //Este set contiene los nombres de los metodos que no se deben ejecutar
  //Si contiene "All" no se ejecuta ningun metodo
  //Debe ser cargado y limpiado en cada DML para no arrastrar
  public static set<String> setExcludedMethods = new set<String>();
  public static final Set<String> MX_RECORDTYPES = new Set<String> {'LAT_MX_ACC_OffTrade', 'LAT_MX_ACC_OnTrade'};

    public static boolean executed = false;

    public static set<Id> accountsInInterface;

    /*****************************************************************************************
    * Nombre del metodo: ValidationRFC
    * Descripcion: Metodo que valida que el RFC ingresado sea valido
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 05/09/2013
    * Modo: before insert, before update
    *****************************************************************************************/

    public static void ValidationRFC(List<Account> triggerNew){
        if(setExcludedMethods.contains('ValidationRFC') || setExcludedMethods.contains('All'))return;

        Boolean esValido = false;
        for (Account acc: triggerNew){
            if(acc.RecordTypeId != Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')){
                if(acc.LAT_MX_FiscalEntityType__c != null){
                    if(acc.CNPJ__c.length() == 12 && acc.LAT_MX_FiscalEntityType__c != 'Company'){
                        acc.CNPJ__c.addError(label.LAT_MX_AP01_00009);
                        //LAT_MX_AP01_00009: El RFC no es válido para el Tipo de persona: 'Física'.
                    }
                    if(acc.CNPJ__c.length() == 13 && acc.LAT_MX_FiscalEntityType__c != 'Individual'){
                        acc.CNPJ__c.addError(label.LAT_MX_AP01_00010);
                        //LAT_MX_AP01_00010: El RFC no es válido para el Tipo de persona: 'Moral'.
                    }
                }
                if(acc.CNPJ__c.length() == 12 || acc.CNPJ__c.length() == 13){
                    esValido = CalculoValidacion(acc.CNPJ__c);
                    if(!esValido){
                        if(buscarExcepcion(acc.CNPJ__c)){
                            acc.CNPJ__c = acc.CNPJ__c.toUpperCase();
                        }else{
                            acc.CNPJ__c.addError(label.LAT_MX_AP01_00001);
                        }
                        //LAT_MX_AP01_00001: Formato de RFC inválido.
                    } else {
                        acc.CNPJ__c = acc.CNPJ__c.toUpperCase();
                    }
                } else {
                    if(buscarExcepcion(acc.CNPJ__c)){
                            acc.CNPJ__c = acc.CNPJ__c.toUpperCase();
                    }else{
                        acc.CNPJ__c.addError(label.LAT_MX_AP01_00001);
                    }
                    //LAT_MX_AP01_00001: Formato de RFC inválido.
                }
            }
        }
    }

    /*****************************************************************************************
    * Nombre del metodo: buscarExcepcion
    * Descripcion: Busca si existe una excepcion para el cnpj
    * Desarrollador: Bruno Vuono
    * Fecha: 04/08/2014
    *****************************************************************************************/

    private static boolean buscarExcepcion(String cnpj){
        List<LAT_RFC__c> tmpList = [Select id from LAT_RFC__c where status__c = 'Aprobado' AND rfc__c =: cnpj limit 1];
        if (tmpList != null && tmpList.size() > 0)return true;
        return false;
    }



    /*****************************************************************************************
    * Nombre del metodo: CalculoValidacion
    * Descripcion: Metodo que recibe un CNPJ y devuelve true si es valido y false si es invalido.
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 05/09/2013
    *****************************************************************************************/

    private static boolean CalculoValidacion(String cnpj){

        Map<String, Integer> mapValoresRFC = new Map<String, Integer> {
            '0' => 0,'1' => 1,'2' => 2,'3' => 3,'4' => 4,'5' => 5,'6' => 6,'7' => 7,'8' => 8,'9' => 9,
            'A' => 10,'B' => 11,'C' => 12,'D' => 13,'E' => 14,'F' => 15,'G' => 16,'H' => 17,'I' => 18,
            'J' => 19,'K' => 20,'L' => 21,'M' => 22,'N' => 23,'Ñ' => 24,'O' => 25,'P' => 26,'Q' => 27,
            'R' => 28,'S' => 29,'T' => 30,'U' => 31,'V' => 32,'W' => 33,'X' => 34,'Y' => 35,'Z' => 36
        };
        Integer suma = 0;
        cnpj = cnpj.toUpperCase();
        for(Integer i = cnpj.length(); i >= 2 ; i--){
            if( !mapValoresRFC.containsKey(cnpj.mid(cnpj.length()-i,1)) ){
                return false;
            }
            if (cnpj.length() == 12 && i == 12){
                suma = suma + (37 * 13);
            }
            suma = suma + (mapValoresRFC.get(cnpj.mid(cnpj.length()-i,1))*i);
        }
        Integer resto = math.mod(suma, 11);
        resto = 11 - resto;

        if(resto == 10){
            if(cnpj.mid(cnpj.length()-1,1) == 'A'){
                return true;
            }else{
                return false;
            }
        }else if(resto == 11){
            resto = 0;
        }
        if(String.valueOf(resto).equals(cnpj.mid(cnpj.length()-1,1))){
            return true;
        }else{
            return false;
        }

    }

/*****************************************************************************************
     * Nombre del metodo: copyPaymentCondition
     * Descripcion: Setea la condicion del padre a todos sus hijos
     * Desarrollador: Zimmic
     * Fecha: 13/07/2016
     * Modo: after update
*****************************************************************************************/
    public static void copyPaymentConditionToChilds(map<Id,Account> newMap, map<Id,Account> oldMap){
        if(!executed){
        List<String> parentIds = new List<String>();
        Map<String,Account> toUpdateMap = new Map<String,Account>();
            String query = 'Select id from Account where id in (\'\''; 

        for(String accId : newMap.keyset()){
           if(isParent(newMap.get(accId)) && newMap.get(accId).Payment_Condition__c != oldMap.get(accId).Payment_Condition__c){
             parentIds.add(accId);
           }
         }
            if(parentIds.size()>0){
                List<Account> customerList = [Select Parent.Payment_Condition__c, 
                    Accept_applications_Incompleted__c,
                                      Accept_Backorder__c, 
                                      Accept_line_incompleted__c, 
                                      Affiliate__c, 
                                      Agency__c, 
                                      Bank__r.Name, 
                                      Bank_number__c, 
                                      Barcode_EDI__c, 
                                      Billing_Address_Code__c, 
                                      Billing_Priority__c, 
                                      Business_Unit__r.CodDefUsuario__c, 
                                      Carriers_Numbers__c, 
                                      Channel__c, 
                                      Checking_account__c, 
                                      Client_code_AN8__c, 
                                      CNPJ__c, 
                                      Corporate_Name__c,
                                      Credit_line__c, 
                                      Current_account__c, 
                                      Customer_Flag__r.CodDefUsuario__c, 
                                      Customer_Geographic_Region__r.CodDefUsuario__c, 
                                      Customer_GL__r.CodDefUsuario__c, 
                                      Customer_Organization__r.CodDefUsuario__c, 
                                      Discount_Group__c, 
                                      Email_NFE__c, 
                                      Fax, 
                                      Freight_Type__c, 
                                      LAT_BR_BusinessSize__c,
                                      LAT_BR_FiscalBenefit__c,
                                      LAT_BR_PriorityLevel__c, 
                                      Municipal_Registration__c, 
                                      Nielsen_Area__r.CodDefUsuario__c, 
                                      OwnerId, 
                                      ParentId,
                                      Parent.Client_code_AN8__c, 
                                      Payment_Condition__c, 
                                      Payment_Condition__r.CodDefUsuario__c, 
                                      Payment_instrument__r.CodDefUsuario__c,
                                      Phone, 
                                      Rating_segmentation_targert_market__c, 
                                      Rating, 
                                      Receiving_Freight__c, 
                                      RecordTypeId, 
                                      Regional__r.CodDefUsuario__c, 
                                      Revenue_Address__c, 
                                      Revenue_City__r.Name,
                                      Revenue_City_Code__c, 
                                      Revenue_Complement__c, 
                                      Revenue_Country__c, 
                                      Revenue_Neighbourhood__c, 
                                      Revenue_Number__c, 
                                      Revenue_Postal_Code__c,  
                                      Revenue_UF__c,
                                      Shipping_Address_Code__c, 
                                      State_registration__c,     
                                      Sub_Channel_Rating__r.CodDefUsuario__c, 
                                      Type,
                                      WebSite,
                                      Yes_No__c,                                  
                                      CurrencyISOCode,
                                      Owner.C_digo_JDE__c,
                                      AddressLine1_AR__c, 
                                      CatCode02_AR__r.CodDefUsuario__c, 
                                      CollectionAgent_AR__r.CodDefUsuario__c,
                                      CustomerPriceGroup_AR__r.CodDefUsuario__c,
                                      CustomerPoRequired_AR__c,
                                      Id,
                                      Name,
                                      Regional_AR__r.CodDefUsuario__c,
                                      Status__c,
                                      AccountNumber,
                                      Business_Unit_AR__r.CodDefUsuario__c,
                                      Client_country_AN8__c, 
                                      Is_interface_Process_AR__c,
                                      LAT_MX_ABCCode__r.CodDefUsuario__c,
                                      LAT_MX_AmountReceiptCopies__c, 
                                      LAT_MX_BatchProcess__r.CodDefUsuario__c,
                                      LAT_MX_BreakDownIEPS__c, 
                                      LAT_MX_CableCodeS__c, 
                                      LAT_MX_Chain__r.CodDefUsuario__c, 
                                      LAT_MX_City__c, 
                                      LAT_MX_County__c, 
                                      LAT_MX_CreditVersionLevel__c, 
                                      LAT_MX_CRMClientCode__c, 
                                      LAT_MX_FiscalEntityType__c, 
                                      LAT_MX_FiscalRate__r.CodDefUsuario__c, 
                                      LAT_MX_Group__r.CodDefUsuario__c, 
                                      LAT_MX_Language__c, 
                                      LAT_MX_Market__c, 
                                      LAT_MX_Neighbourhood__c, 
                                      LAT_MX_PostalCode__r.Name, 
                                      LAT_MX_RelatedAddressAN8__c, 
                                      LAT_MX_RouteCode__r.CodDefUsuario__c, 
                                      LAT_MX_State__c, 
                                      LAT_MX_ZoneNumber__r.CodDefUsuario__c, 
                                      Owner.Email, 
                                      Owner.Name,
                                      Return_JDE_Integration__c, 
                                      Segmentation_Type_on_trade__c
                                      from Account where parentId in: parentIds];
                for(Account acc : customerList){
                if(acc.Payment_Condition__c != acc.Parent.Payment_Condition__c){
                  acc.Payment_Condition__c = acc.Parent.Payment_Condition__c;
                  toUpdateMap.put(acc.id, acc);
                        query += ', \'' + acc.id + '\'';
                }
                }
            }
            query += ')';
            system.debug('aaaaa ' + query);
            system.debug('bbbbb ' + toUpdateMap);
            if(toUpdateMap.size() > 0){
                LAT_MX_AccountIntegrateBatch batchProcess = new  LAT_MX_AccountIntegrateBatch(toUpdateMap,query);
                Database.executeBatch(batchProcess, 1);
                executed = true;
            }
        }


  }

  public static Boolean isParent(Account acc ){
    return acc.type == 'Payer' && acc.ParentId == null;
  }


   /*****************************************************************************************
    * Nombre del metodo: FieldMissingDocumentsNewAccount
    * Descripcion: Completo el campo 'Missing Documents' cuando se inserta un Account
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 24/09/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void FieldMissingDocumentsNewAccount(List<Account> triggerNew,map<Id,Account> oldMap){
        System.debug('%%%%%% entramos en FieldMissingDocumentsNewAccount');
        System.debug('%%%%%% setExcludedMethods: '+ setExcludedMethods);

        if(setExcludedMethods.contains('FieldMissingDocumentsNewAccount') || setExcludedMethods.contains('All'))return;

        List<Account> listAccounts = new List<Account>();

        for(Account acc: triggerNew){
            if(OldMap == null || (acc.Channel__c != oldMap.get(acc.id).Channel__c)){
                listAccounts.add(acc);
            }
        }

        if(!listAccounts.isEmpty()){

            list<LAT_MX_CS001_AccountDocuments__c> listAccountDocs = LAT_MX_CS001_AccountDocuments__c.getAll().values();
            set<String> setChannels = new set<String>();

            map<String, LAT_MX_CS001_AccountDocuments__c> mapCS = new map<String, LAT_MX_CS001_AccountDocuments__c>();

            for(LAT_MX_CS001_AccountDocuments__c accDoc: listAccountDocs){
                setChannels.add(accDoc.LAT_MX_RequiredForChannel__c);
            }

            for (Account acc : listAccounts) {
                list<String> listMissingDocs = new list<String>();      
                System.debug('%%%% setChannels : '+ setChannels);
                System.debug('%%%% acc.Channel__c : '+ acc.Channel__c);
                String MissingDocs = '';       
                if(setChannels.contains(acc.Channel__c)){
                    String MissingDoc;
                    for(LAT_MX_CS001_AccountDocuments__c accDoc: listAccountDocs){
                        System.debug('%%%% accDoc.LAT_MX_RequiredForFiscalEntityType__c : '+ accDoc.LAT_MX_RequiredForFiscalEntityType__c);
                        System.debug('%%%% acc.LAT_MX_FiscalEntityType__c : '+ acc.LAT_MX_FiscalEntityType__c);
                        System.debug('%%%% accDoc.LAT_MX_RequiredForFiscalEntityType__c == acc.LAT_MX_FiscalEntityType__c : '+ accDoc.LAT_MX_RequiredForFiscalEntityType__c == acc.LAT_MX_FiscalEntityType__c);
       
                        if(accDoc.LAT_MX_RequiredForChannel__c == acc.Channel__c
                            && accDoc.LAT_MX_RequiredForType__c == acc.Type
                            && accDoc.LAT_MX_RequiredForFiscalEntityType__c == acc.LAT_MX_FiscalEntityType__c
                            ){
                              MissingDoc = accDoc.LAT_MX_TextToShow__c + ' (' + accDoc.Name.substring(0, 7) + ')';
                              listMissingDocs.add(MissingDoc);
                        }
                    }
                    
                }
                if(!listMissingDocs.isEmpty()){
                    listMissingDocs.sort();
                    for(String doc: listMissingDocs){
                        if(MissingDocs == ''){
                            MissingDocs = '- ' + doc;
                        } else {
                            MissingDocs = MissingDocs + '\n' + '- ' + doc;
                        }
                    }
                }
                acc.LAT_MX_MissingDocuments__c = MissingDocs;
            }
        }
    }

    /*****************************************************************************************
    * Nombre del metodo: customerInterfase
    * Descripcion: Metodo que realiza de envio del cliente para registracion en JDE
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 07/10/2013
    * Modo: After Update
    *****************************************************************************************/
    public static void customerInterfase(List<Account> triggerNew, map<Id, Account> oldMap){
        List<String> accIds = new List<String>();
        if(setExcludedMethods.contains('customerInterfase') || setExcludedMethods.contains('All'))return;

        for(Account acc : triggerNew){
            Boolean SendToJDE = false;
            if(acc.Status__c != oldMap.get(acc.Id).Status__c && (!acc.Is_Interface_Process_AR__c)){
                if(acc.Status__c == 'Directed to be registered In JDE'){
                    SendToJDE = true;
                }
                if(acc.Status__c == 'Inactive Account' && oldMap.get(acc.Id).Status__c == 'Cliente cadastrado no JDE'){
                    SendToJDE = true;
                }
                if(acc.Status__c == 'Being reactivated' && oldMap.get(acc.Id).Status__c == 'Inactive Account'){
                    SendToJDE = true;
                }
            if(acc.Status__c == 'Modification requested in CRM'){
                    SendToJDE = true;
                }
            }
            if(SendToJDE){
                if(accountsInInterface == null){
                    accountsInInterface = new set<Id>();
                }
                if(!accountsInInterface.contains(acc.Id)){
                    accountsInInterface.add(acc.Id);
                    if (LAT_WS_Utils.getWSEndpoint('12').startsWith('https')) {
                        accIds.add(String.valueof(acc.Id));
                    } else {
                        LAT_MX_WS01_CustomerHandlerInterface.CustomerInterfaceJDE(String.valueof(acc.Id));
                    }
                }
            }

        }

        if(accIds.size() > 0)LAT_WS_CustomerHandlerInterface.updateCustomerStatus(accIds);
        for(String s : accIds){
            LAT_WS_CustomerHandlerInterface.CustomerInterfaceJDE(s);
        }
    }

    /*****************************************************************************************
    * Nombre del metodo: FielsdUpdate
    * Descripcion: Metodo que completa los campos Nielsen_Area__c y Regional_Manager__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 08/10/2013
    * Modo:  before insert, before update
    *****************************************************************************************/
    public static void FielsdUpdate(List<Account> triggerNew){

      if(setExcludedMethods.contains('FielsdUpdate') || setExcludedMethods.contains('All'))return;

        Set<String> setIdPostalCode = new Set<String>();
        Set<String> setIdOwners = new Set<String>();

        for(Account acc : triggerNew){
            if(acc.LAT_MX_PostalCode__c != null){
                setIdPostalCode.add(acc.LAT_MX_PostalCode__c);
            }
            //if(acc.Regional__c != null){ --> Cambio regional MX
            //    setComercialRegions.add(acc.Regional__c);
            //}
            setIdOwners.add(acc.OwnerId);
        }

        Map<String,String> mapOwnerRegion = new Map<String,String>();
        for(User us: [SELECT Id, C_digo_JDE__c FROM User WHERE Id IN: setIdOwners]) {
            if (us.C_digo_JDE__c != null && us.C_digo_JDE__c.length() >= 1) {
                // MX define ahora que la region se calcula en base al primer caracter del codigo JDE del KAMy
                mapOwnerRegion.put(us.Id, us.C_digo_JDE__c.substring(0,1));
                System.debug('************ ID REGION:' + us.C_digo_JDE__c.substring(0,1));
            }
        }


        String rtPostalCode = Global_RecordTypeCache.getRtId('LAT_MX_PCD_PostalCode__c' + 'LAT_MX_PCD_Standard');
        Set<String> setNielsenArea = new Set<String>();
        Map<String,LAT_MX_PCD_PostalCode__c> mapIdPostalCode = new Map<String,LAT_MX_PCD_PostalCode__c>();

        if(!setIdPostalCode.isEmpty()){
            for(LAT_MX_PCD_PostalCode__c pc: [SELECT Id, RecordTypeId, LAT_MX_NilsenArea__c FROM LAT_MX_PCD_PostalCode__c WHERE Id IN: setIdPostalCode AND RecordTypeId =: rtPostalCode]){
                setNielsenArea.add(pc.LAT_MX_NilsenArea__c);
                mapIdPostalCode.put(pc.Id,pc);
            }
        }

        String rtUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard');
        Map<String,String> mapUdc = new Map<String,String>();
        Set<String> setNamesUDC = new Set<String>();
        // Map<String,String> mapNamesIdUDC = new Map<String,String>(); -> Cambio Regional MX
        Map<String,String> mapUdc0102 = new Map<String,String>();

        if( (!setNielsenArea.isEmpty()) || (!mapOwnerRegion.isEmpty()) ){
            for(UDC__c udc: [SELECT Id, Name, CodProd__c, CodUs__c, CodDefUsuario__c FROM UDC__c WHERE (Name IN: setNielsenArea OR (Internal_id__C like '12-%-01-02' AND CodDefUsuario__c IN: mapOwnerRegion.values())) AND RecordTypeId =: rtUDC]){
                System.debug('-> udc.CodDefUsuario__c=[' + udc.CodDefUsuario__c + '] udc.CodProd__c=[' + udc.CodProd__c + '] udc.CodUs__c=' + udc.CodUs__c);
                if(setNielsenArea.contains(udc.Name)){
                    mapUdc.put(udc.Name,Udc.Id);
                }
                // if(setComercialRegions.contains(udc.Id)){ --> Cambio RegionalMgr MX (DS)
                if (udc.CodProd__c == '01' && udc.CodUs__c == '02') {
                    mapUdc0102.put(udc.CodDefUsuario__c,udc.Id);
                    System.debug('************ udc.CodDefUsuario__c: [' + udc.CodDefUsuario__c + '] udc.Id=' + udc.Id);
                }
            }
        }

        // Regional Manager no se necesita mas en MX
        /*
        Map<String,String> mapIdUdcRegional = new Map<String,String>();
        if(!mapNamesIdUDC.isEmpty()){
            for(User us: [SELECT Id, LAT_MX_CommercialRegion__c FROM User WHERE LAT_MX_CommercialRegion__c IN: mapNamesIdUDC.Keyset()]){
                if(mapNamesIdUDC.containsKey(us.LAT_MX_CommercialRegion__c)){
                    mapIdUdcRegional.put(mapNamesIdUDC.get(us.LAT_MX_CommercialRegion__c),us.id);
                }
            }
        }
        */

        for(Account acc : triggerNew){
            if(acc.LAT_MX_PostalCode__c != null){
                if(mapIdPostalCode.containsKey(acc.LAT_MX_PostalCode__c)){
                    if(mapUdc.containsKey(mapIdPostalCode.get(acc.LAT_MX_PostalCode__c).LAT_MX_NilsenArea__c)){
                        acc.Nielsen_Area__c = mapUdc.get(mapIdPostalCode.get(acc.LAT_MX_PostalCode__c).LAT_MX_NilsenArea__c);
                    }
                }
            }else{
                acc.Nielsen_Area__c = null;
            }
            // Regional Manager no se necesita mas en MX
            /*if(acc.Regional__c != null){
                if(mapIdUdcRegional.containsKey(acc.Regional__c)){
                    acc.Regional_Manager__c = mapIdUdcRegional.get(acc.Regional__c);
                }
            }else{
                acc.Regional_Manager__c = null;
            }*/
            if (mapOwnerRegion.containsKey(acc.OwnerId)) {
                acc.Regional_AR__c = mapUdc0102.get(mapOwnerRegion.get(acc.OwnerId));
                System.debug('************ acc.Regional_AR__c: ' + acc.Regional_AR__c);
            }
        }
    }

    /*********************************************************************************************************
    * Nombre del metodo: LATAccount
    * Descripcion: Creates a LAT_Account__c for Account
    * Desarrollador: Denis Aranda
    * Fecha: 10/10/2013
    * Modo: After Insert
    *********************************************************************************************************/
    public static void LATAccount(List<Account> triggerNew){

      if(setExcludedMethods.contains('LATAccount') || setExcludedMethods.contains('All'))return;

        List <LAT_ACCOUNT__c> listLATAccount = new List <LAT_ACCOUNT__c>();
        for(Account acc: triggerNew ){
            listLATAccount.add(new LAT_ACCOUNT__c(LAT_Accountid__c = acc.id, RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ACCOUNT__c'+'LAT_MX_LAC_Standard')));
        }

        insert listLATAccount;

    }

    /*********************************************************************************************************
    * Nombre del metodo: AccountInactivation
    * Descripcion: Method that validates the Account that is being inactivated
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 17/10/2013
    * Modo: Before Update
    *********************************************************************************************************/
    public static void AccountInactivation(List<Account> triggerNew, map<Id, Account> oldMap){

        if(setExcludedMethods.contains('AccountInactivation') || setExcludedMethods.contains('All'))return;

        Boolean isInactivation = false;

        for(Account acc: triggerNew){
            if(acc.Status__c == 'Inactive Account' && OldMap.get(acc.Id).Status__c != acc.Status__c){
                isInactivation = true;
            }
        }

        if(isInactivation){

            Id IdProfileUser = userinfo.getProfileid();
            Profile perfil = LAT_GlobalProfileCache.getProfileById(IdProfileUser);

            Set<String> setProfilesOnTrade = new Set<String>();
            setProfilesOnTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX_Administracion Comercial'));
            setProfilesOnTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_AdministracionComercial'));
            setProfilesOnTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX_Business Administrator'));
            setProfilesOnTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_BusinessAdministrator'));

            Set<String> setProfilesOffTrade = new Set<String>();
            setProfilesOffTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX_Administracion Comercial'));
            setProfilesOffTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_AdministracionComercial'));
            setProfilesOffTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX_Creditos y Cobranzas'));
            setProfilesOffTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_CreditosyCobranzas'));
            setProfilesOffTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX_Business Administrator'));
            setProfilesOffTrade.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_MX2_BusinessAdministrator'));

            for(Account acc: triggerNew){
                if(acc.Status__c == 'Inactive Account' && OldMap.get(acc.Id).Status__c != acc.Status__c){
                    //On Trade Account Validations
                    if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'LAT_MX_ACC_OnTrade')){
                        if (setProfilesOnTrade.contains(IdProfileUser) || perfil.Name == 'System Administrator' 
                          || perfil.Name == 'LAT_SystemAdministrator' || perfil.Name == 'Administrador del sistema' 
                          || perfil.Name == 'Administrador do sistema' || perfil.Name == 'LAT_MX_System Administrator'){
                            if(OldMap.get(acc.Id).Status__c == 'Cliente cadastrado no CRM' || OldMap.get(acc.Id).Status__c == 'Cliente cadastrado no JDE'){
                                if(acc.Other_Notes__c == null){
                                    acc.Other_Notes__c.addError(label.LAT_MX_AP01_00014);
                                    //LAT_MX_AP01_00014: Se debe completar el campo Observaciones para inactivar el cliente.
                                }
                            }else if(perfil.Name != 'System Administrator' && perfil.Name != 'Administrador del sistema' && perfil.Name != 'LAT_SystemAdministrator' && perfil.Name != 'Administrador do sistema' && perfil.Name != 'LAT_MX_System Administrator') {
                                acc.addError(label.LAT_MX_AP01_00015);
                                // LAT_MX_AP01_00015: No es posible inactivar un cliente que no ha sido registrado en el sistema
                            }
                        }else{
                            acc.addError(label.LAT_MX_AP01_00016);
                            //LAT_MX_AP01_00016: Solo usuarios con perfil System Administrator, LAT_MX_System Administrator o LAT_MX_Administracion Comercial pueden inactivar clientes On Trade.
                        }
                    }

                    //Off Trade Account Validations
                    if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'LAT_MX_ACC_OffTrade')){
                        if (setProfilesOffTrade.contains(IdProfileUser) || perfil.Name == 'System Administrator' || perfil.Name == 'LAT_SystemAdministrator' || perfil.Name == 'Administrador del sistema' || perfil.Name == 'Administrador do sistema' || perfil.Name == 'LAT_MX_System Administrator'){
                            if(OldMap.get(acc.Id).Status__c == 'Cliente cadastrado no CRM' || OldMap.get(acc.Id).Status__c == 'Cliente cadastrado no JDE'){
                                if(acc.Other_Notes__c == null){
                                    acc.Other_Notes__c.addError(label.LAT_MX_AP01_00014);
                                    //LAT_MX_AP01_00014: Se debe completar el campo Observaciones para inactivar el cliente.
                                }
                            }else if(perfil.Name != 'System Administrator' && perfil.Name != 'LAT_SystemAdministrator' && perfil.Name != 'Administrador del sistema' && perfil.Name != 'Administrador do sistema' && perfil.Name != 'LAT_MX_System Administrator') {
                                acc.addError(label.LAT_MX_AP01_00015);
                                // LAT_MX_AP01_00015: No es posible inactivar un cliente que no ha sido registrado en el sistema
                            }
                        }else{
                            acc.addError(label.LAT_MX_AP01_00017);
                            //LAT_MX_AP01_00017: Solo usuarios con perfil System Administrator, LAT_MX_System Administrator, LAT_MX_Administracion Comercial o LAT_MX_Creditos y Cobranzas pueden inactivar clientes Off Trade.
                        }
                    }
                }
            }
        }
    }

    /*********************************************************************************************************
    * Nombre del metodo: filtersValidationUDC
    * Descripcion: Method that the filters of the UDC fields that have options Filters
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 30/10/2013
    * Modo: Before Insert, Before Update
    *********************************************************************************************************/
    public static void filtersValidationUDC(List<Account> triggerNew, Map<Id,Account> oldMap){

    if(setExcludedMethods.contains('filtersValidationUDC') || setExcludedMethods.contains('All'))return;

        String rtUDC = Global_RecordTypeCache.getRtId('UDC__c'+'LAT_MX_UDC_Standard');

        Set<String> setUDCIds = new Set<String>();

        for(Account acc: triggerNew){
            if(acc.Regional__c != null && (oldMap == null || (oldMap != null && acc.Regional__c != oldMap.get(acc.Id).Regional__c))) setUDCIds.add(acc.Regional__c);
            if(acc.Business_Unit_AR__c != null && (oldMap == null || (oldMap != null && acc.Business_Unit_AR__c != oldMap.get(acc.Id).Business_Unit_AR__c))) setUDCIds.add(acc.Business_Unit_AR__c);
            if(acc.Customer_GL__c != null && (oldMap == null || (oldMap != null && acc.Customer_GL__c != oldMap.get(acc.Id).Customer_GL__c))) setUDCIds.add(acc.Customer_GL__c);
            if(acc.LAT_MX_ABCCode__c != null && (oldMap == null || (oldMap != null && acc.LAT_MX_ABCCode__c != oldMap.get(acc.Id).LAT_MX_ABCCode__c))) setUDCIds.add(acc.LAT_MX_ABCCode__c);
            if(acc.LAT_MX_RouteCode__c != null && (oldMap == null || (oldMap != null && acc.LAT_MX_RouteCode__c != oldMap.get(acc.Id).LAT_MX_RouteCode__c))) setUDCIds.add(acc.LAT_MX_RouteCode__c);
            if(acc.LAT_MX_BatchProcess__c != null && (oldMap == null || (oldMap != null && acc.LAT_MX_BatchProcess__c != oldMap.get(acc.Id).LAT_MX_BatchProcess__c))) setUDCIds.add(acc.LAT_MX_BatchProcess__c);
            if(acc.LAT_MX_ZoneNumber__c != null && (oldMap == null || (oldMap != null && acc.LAT_MX_ZoneNumber__c != oldMap.get(acc.Id).LAT_MX_ZoneNumber__c))) setUDCIds.add(acc.LAT_MX_ZoneNumber__c);
            if(acc.LAT_MX_Chain__c != null && (oldMap == null || (oldMap != null && acc.LAT_MX_Chain__c != oldMap.get(acc.Id).LAT_MX_Chain__c))) setUDCIds.add(acc.LAT_MX_Chain__c);
            if(acc.LAT_MX_Group__c != null && (oldMap == null || (oldMap != null && acc.LAT_MX_Group__c != oldMap.get(acc.Id).LAT_MX_Group__c))) setUDCIds.add(acc.LAT_MX_Group__c);
            if(acc.LAT_MX_FiscalRate__c != null && (oldMap == null || (oldMap != null && acc.LAT_MX_FiscalRate__c != oldMap.get(acc.Id).LAT_MX_FiscalRate__c))) setUDCIds.add(acc.LAT_MX_FiscalRate__c);
        }

        Map<Id,UDC__c> mapIdUDC = new Map<Id,UDC__c>();
        if(!setUDCIds.isEmpty()){
            mapIdUDC = new Map<Id,UDC__c>([SELECT Id, RecordTypeId, LAT_MX_FilterKey__c FROM UDC__c WHERE Id IN: setUDCIds]);
        }

        for(Account acc: triggerNew){
            if(acc.Regional__c != null && setUDCIds.contains(acc.Regional__c) && !(mapIdUDC.get(acc.Regional__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.Regional__c).LAT_MX_FilterKey__c == '01-01-MX')){
                acc.Regional__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.Business_Unit_AR__c != null && setUDCIds.contains(acc.Business_Unit_AR__c) && !(mapIdUDC.get(acc.Business_Unit_AR__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.Business_Unit_AR__c).LAT_MX_FilterKey__c == 'DF-CRM-MX')){
                acc.Business_Unit_AR__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.Customer_GL__c != null && setUDCIds.contains(acc.Customer_GL__c) && !(mapIdUDC.get(acc.Customer_GL__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.Customer_GL__c).LAT_MX_FilterKey__c == 'GL-55-MX')){
                acc.Customer_GL__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.LAT_MX_ABCCode__c != null && setUDCIds.contains(acc.LAT_MX_ABCCode__c) && !(mapIdUDC.get(acc.LAT_MX_ABCCode__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.LAT_MX_ABCCode__c).LAT_MX_FilterKey__c == 'A2-H01-MX')){
                acc.LAT_MX_ABCCode__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.LAT_MX_RouteCode__c != null && setUDCIds.contains(acc.LAT_MX_RouteCode__c) && !(mapIdUDC.get(acc.LAT_MX_RouteCode__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.LAT_MX_RouteCode__c).LAT_MX_FilterKey__c == 'RT-42-MX')){
                acc.LAT_MX_RouteCode__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.LAT_MX_BatchProcess__c != null && setUDCIds.contains(acc.LAT_MX_BatchProcess__c) && !(mapIdUDC.get(acc.LAT_MX_BatchProcess__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.LAT_MX_BatchProcess__c).LAT_MX_FilterKey__c == '30-01-MX')){
                acc.LAT_MX_BatchProcess__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.LAT_MX_ZoneNumber__c != null && setUDCIds.contains(acc.LAT_MX_ZoneNumber__c) && !(mapIdUDC.get(acc.LAT_MX_ZoneNumber__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.LAT_MX_ZoneNumber__c).LAT_MX_FilterKey__c == 'ZN-40-MX')){
                acc.LAT_MX_ZoneNumber__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.LAT_MX_Chain__c != null && setUDCIds.contains(acc.LAT_MX_Chain__c) && !(mapIdUDC.get(acc.LAT_MX_Chain__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.LAT_MX_Chain__c).LAT_MX_FilterKey__c == '10-01-MX')){
                acc.LAT_MX_Chain__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.LAT_MX_Group__c != null && acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'LAT_MX_ACC_OffTrade') && setUDCIds.contains(acc.LAT_MX_Group__c) && !(mapIdUDC.get(acc.LAT_MX_Group__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.LAT_MX_Group__c).LAT_MX_FilterKey__c == '09-01-MX')){
                acc.LAT_MX_Group__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.LAT_MX_Group__c != null && acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'LAT_MX_ACC_OnTrade') && setUDCIds.contains(acc.LAT_MX_Group__c) && !(mapIdUDC.get(acc.LAT_MX_Group__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.LAT_MX_Group__c).LAT_MX_FilterKey__c == 'ON-CRM-MX')){
                //acc.LAT_MX_Group__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
            if(acc.LAT_MX_FiscalRate__c != null && setUDCIds.contains(acc.LAT_MX_FiscalRate__c) && !(mapIdUDC.get(acc.LAT_MX_FiscalRate__c).RecordTypeId == rtUDC && mapIdUDC.get(acc.LAT_MX_FiscalRate__c).LAT_MX_FilterKey__c == 'TX-CRM-MX')){
                acc.LAT_MX_FiscalRate__c.addError(label.LAT_MX_AP01_00018);
                //LAT_MX_AP01_00018: El valor seleccionado es incorrecto para este campo.
            }
        }

    }


    /*********************************************************************************************************
    * Nombre del metodo: updatesInformationUnfilled
    * Descripcion: required fiedls to be completed to be approved
    * Desarrollador: Denis Aranda
    * Fecha: 05/02/2014
    * Modo: Before Insert, Before Update
    *********************************************************************************************************/
    public static void updatesInformationUnfilled(List<Account> triggerNew){

      if(setExcludedMethods.contains('updatesInformationUnfilled') || setExcludedMethods.contains('All'))return;

        string recordTypeMexOn = Global_RecordTypeCache.getRtId('Account'+'LAT_MX_ACC_OnTrade');
        string recordTypeMexOff = Global_RecordTypeCache.getRtId('Account'+'LAT_MX_ACC_OffTrade');

        Set<Id> setAccountIds = new Set<Id>();

        for(Account acc: triggerNew){
            if(acc.RecordTypeId == recordTypeMexOn ){
                setAccountIds.add(acc.Id);
                acc.LAT_InformationUnfilled__c = '';
                //acc.LAT_InformationUnfilled__c += acc.LAT_MX_Chain__c == null ? Schema.Account.Field.LAT_MX_Chain__c.getDescribe().getLabel() + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += acc.LAT_MX_Group__c == null ? Schema.Account.Field.LAT_MX_Group__c.getDescribe().getLabel() + '<br/>' : '';
                if(trigger.isInsert){
                    acc.LAT_InformationUnfilled__c += label.LAT_MX_AP01_00025;
                }
            }else if(acc.RecordTypeId == recordTypeMexOff ){
                acc.LAT_InformationUnfilled__c = '';
                //acc.LAT_InformationUnfilled__c += acc.LAT_MX_BreakDownIEPS__c == null ? Schema.Account.Field.LAT_MX_BreakDownIEPS__c.getDescribe().getLabel() + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += acc.LAT_MX_Chain__c == null ? Schema.Account.Field.LAT_MX_Chain__c.getDescribe().getLabel() + '<br/>' : '';
                acc.LAT_InformationUnfilled__c += acc.LAT_MX_Group__c == null ? Schema.Account.Field.LAT_MX_Group__c.getDescribe().getLabel() + '<br/>' : '';
                //acc.LAT_InformationUnfilled__c += acc.LAT_MX_SupplierNumber__c == null ? Schema.Account.Field.LAT_MX_SupplierNumber__c.getDescribe().getLabel() + '<br/>' : '';
            }
        }

        if(trigger.isUpdate){
            List<Contact> listContacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN: setAccountIds];
            Set<Id> setAccountHasContact = new Set<Id>();
            if(!listContacts.isEmpty()){
                for(Contact con: listContacts){
                    setAccountHasContact.add(con.AccountId);
                }
            }
            for(Account acc: triggerNew){
                if(!setAccountHasContact.contains(acc.Id) && acc.RecordTypeId == recordTypeMexOn){
                    acc.LAT_InformationUnfilled__c += label.LAT_MX_AP01_00025;
                }
            }
        }
    }

    /*********************************************************************************************************
    * Nombre del metodo: validatesAN8BeforeDeletion
    * Descripcion: Blocks an Account Deletion if the Account has been registered in JDE
    * Desarrollador: Javier Fagian
    * Fecha: 11/12/2017
    * Modo: Before Delete
    *********************************************************************************************************/
    public static void validatesAN8BeforeDeletion(List<Account> accs) {

        for (Account a : accs) {
            if (a.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'LAT_MX_ACC_OffTrade') 
                || a.RecordTypeId == Global_RecordTypeCache.getRtId('Account'+'LAT_MX_ACC_OnTrade')) {
                System.debug('%%%% entramos en validatesAN8BeforeDeletion con acc : '+a);
                if (a.Client_code_AN8__c != null && a.Client_code_AN8__c != '') {
                  System.debug('%%%% entramos a borrar con acc : '+a);
                    a.addError(Label.LAT_MX_AP01_00027);
                    //'No se puede eliminar una cuenta que ya fue registrada en JDE.'
                } else if (a.Status__c == 'Directed to be registered In JDE') {
                    System.debug('%%%% entramos a borrar2 con acc : '+a);
                    a.addError(Label.LAT_MX_AP01_00028);
                    //'No se puede eliminar una cuenta que fue encaminada para Registrar en JDE.'
                }
            }
        }
    }


    /*********************************************************************************************************
    * Nombre del metodo: registerAccountActivateDeactivateLATAccount
    * Descripcion: Sets the accounts as registered in JDE and activates or deactivates the associated lat accounts
    * Desarrollador: Zimmic
    * Fecha: 4/10/2018
    * Modo: Before Update
    *********************************************************************************************************/
    public static void registerAccountActivateDeactivateLATAccount(List<Account> accs) {

      for(Account acc :accs){
        if(acc.status__c.equalsIgnoreCase('Activo MX') || acc.status__c.equalsIgnoreCase('Inactivo MX')){
          
          LAT_Account__c latAcc = [SELECT Id, LAT_ID_Status__c FROM LAT_Account__c WHERE Id = :acc.LAT_Account__c];
          if(latAcc != null) {
            if(acc.status__c.equalsIgnoreCase('Activo MX')) {
              latAcc.LAT_ID_Status__c = 'Activo';
            } else {
              latAcc.LAT_ID_Status__c = 'Inactivo'; 
            }
            update latAcc;
          }
          acc.status__c = 'Cliente cadastrado no JDE';
        }        
      }
    }
}