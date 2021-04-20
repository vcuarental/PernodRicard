public class LAT_MX_OnTrade_Account {
    private static final String BREAK_LINE    = '<br/>';
    private static boolean running = false;

    // Runs on trigger Before Update and Before Insert
    public static void updateCountryCodeAn8(List <Account> newAccts, Map<Id, Account> oldMap, Boolean isInsert) {
        for (Account a : newAccts) {
            if ((isInsert &&  String.isNotBlank(a.Client_code_AN8__c)) || String.isNotBlank(a.Client_code_AN8__c) && oldMap.get(a.Id).Client_code_AN8__c != a.Client_code_AN8__c) {
                a.Client_country_AN8__c = '12-On-' + a.Client_code_AN8__c;
            }
        }
    }

    public static void notifyOnTradeChange (List <Account> newAccts) {
        List <String> accts = new List <String>();
        final String registeredInCRM = 'Directed to be registered In JDE';
        final String modificationRequested = 'Modification requested in CRM';
        final String cadastradoJDE = 'Cliente cadastrado no JDE';

        for (Account a : newAccts) {
            if (a.Status__c == registeredInCRM || a.Status__c == modificationRequested || (a.status__C == 'Inactive Account')) {
                if (String.isNotBlank(a.ParentId)) {
                    system.debug('%%%%%%%%%%%%%% soy hijo de : ' + a.ParentId);
                    accts.add(a.ParentId);
                } else {
                    system.debug('%%%%%%%%%%%%%% soy padre : ' + a.id);
                    accts.add(a.Id);
                }
            }
        }

        if (!accts.isEmpty()) {
            LAT_MX_OnTrade_Account.callOnTradeChangeWS(accts);
        }
    }

    public static void notifyOnTradeChangeSync (List <Account> newAccts) {
        List <String> accts = new List <String>();
        final String registeredInCRM = 'Directed to be registered In JDE';
        final String modificationRequested = 'Modification requested in CRM';

        for (Account a : newAccts) {
            if (a.Status__c == registeredInCRM || a.Status__c == modificationRequested || (a.status__C == 'Inactive Account')) {
                if (String.isNotBlank(a.ParentId)) {
                    accts.add(a.ParentId);
                } else {
                    accts.add(a.Id);
                }
            }
        }

        if (!accts.isEmpty()) {
            LAT_MX_OnTrade_Account.callOnTradeChangeWSSync(accts);
        }
    }

    public static void updateStatus (List <Account> newAccts, Map<Id, Account> oldMap) {
        final String modifiedInCRM = 'Modification requested in CRM';
        final String cadastradoJDE = 'Cliente cadastrado no JDE';
        final String integrado = 'Integrado Compuarte';
        final String registeredInCRM = 'Directed to be registered In JDE';
        final String erroJDE = 'Erro JDE';
        final String integradoOK = 'Integrado Compuarte - OK';
        final String pendingInactivation = 'Pending Inactivation Approval';
        final String naoAprovado = 'Não aprovado';
        final String cadastradoCRM = 'Cliente cadastrado no CRM';
        
        for (Account a : newAccts) {
            system.debug('1 - ############# en el updateStatus - cuenta: ' + a.id + ' - status: ' +a.Status__c);
            if (pendingInactivation != a.Status__c) {
                if (integrado == a.Status__c) {
                    system.debug('2 - ############# en el updateStatus - verifica status: ' + a.id + ' - status: ' +a.Status__c);

                    a.Return_JDE_Integration__c = integrado;
                    a.Status__c = cadastradoJDE;

                    system.debug('3 - ############# en el updateStatus - setea status: ' + a.id + ' - new status: ' +a.Status__c);
                }

                system.debug('--------------account status : ' + a.Status__c);
                system.debug('--------------account old status : ' + oldMap.get(a.id).Status__c);
                system.debug ('-------------account Return_JDE_Integration__c: ' + a.Return_JDE_Integration__c);
                system.debug ('-------------account old Return_JDE_Integration__c: ' + oldMap.get(a.id).Return_JDE_Integration__c);

                // Que no este rechazado o en proceso de aprobacion
                if (!(naoAprovado == a.Status__c || cadastradoCRM == a.Status__c)) {
                    if (cadastradoJDE == oldMap.get(a.id).Status__c && !(integrado == a.Return_JDE_Integration__c) && !isInactivation(a, oldMap.get(a.id)) || (a.Status__c == erroJDE && a.Return_JDE_Integration__c.contains('Error -'))){
                        system.debug('en el if');
                        a.Status__c = modifiedInCRM;
                    } else if (isInactivation(a, oldMap.get(a.id))) {
                        a.status__c = registeredInCRM;
                    }
                }

                if (a.Return_JDE_Integration__c !=  null && integrado == a.Return_JDE_Integration__c) {
                    a.Return_JDE_Integration__c += ' - OK';
                } else {
                    if (a.Return_JDE_Integration__c != null && !a.Return_JDE_Integration__c.contains(integrado)) {
                        a.Return_JDE_Integration__c = 'Error - ' + a.Return_JDE_Integration__c;
                    }
                }
            }
        }
    }

    public static Boolean isInactivation(Account newAcc, Account oldAcc){
        return newAcc.Status__c == 'Inactive Account' && oldAcc.Status__c != 'Inactive Account';
    }

    // Agregado por conversacion con Jose Luis y Raul, los hijos heredan el valor del campo
    // Convenio PRM del padre
  /*
  @future
    public static void validateConvenioPRM(Set<Id> newSet) {
        final List <Account> allAcc = [SELECT Id, ParentId from Account WHERE id IN :newSet];
        Map <Id, Account> hijos = new Map <Id, Account>();
        Map <Id, Account> padres = new Map <Id, Account>();
        Map <Id, Account> todos = new Map <Id, Account> ();
        //Separo las Account padres de los hijos
        for (Account a : allAcc) {
            if (a.ParentId == null) {   // es un padre
                padres.put(a.Id, a);
            } else {                    // es hijo
                hijos.put(a.Id, a);
                if (!padres.containsKey(a.ParentId)) padres.put(a.ParentId, null);
            }
        }

        // Cargo todos los hijos de los padres que me llegan (que pueden no estar en la lista)
        final List <Account> children = [SELECT Id, ParentId from Account WHERE ParentId IN :padres.keySet()];
        hijos.putAll(children); // agrego los hijos que no vienen por trigger
        // Cargo el mapa con todas mis listas
        todos.putAll(children);
        todos.putAll(hijos);
        todos.putAll(padres);


        // cargo todos los LAT_Account
        final List <LAT_Account__c> latAccount = [SELECT LAT_Convenio_prm__c, LAT_Accountid__c FROM LAT_ACCOUNT__c WHERE LAT_Accountid__c IN :todos.keySet()];

        Map <Id, LAT_Account__c> latAccMap = new Map <Id, LAT_Account__c>();

        // Cargo todos los LAT_Account con el id de la Account a la que pertenecen
        for (LAT_Account__c la : latAccount) {
            latAccMap.put(la.LAT_Accountid__c, la);
        }

        // actualizo hijos
        for (Account a : hijos.values()) {
            latAccMap.get(a.Id).LAT_Convenio_prm__c = latAccMap.get(a.ParentId).LAT_Convenio_prm__c;
        }

        // Actualizo los LAT_Account de los hijos
        if (!latAccMap.values().isEmpty()) update latAccMap.values();
    }
    */

    // Agregegado por Raul y Jose Luis ya que es un campo necesario para Compuarte
    public static void validarZipCode(List <LAT_Account__c> latAccounts, map <ID, LAT_Account__c> oldLatAccounts, boolean isInsert) {
        Set<String> allZip = new Set<String>();
        Set<String> actualZip = new Set<String>();
        for (LAT_Account__c la : latAccounts) {
            if (String.isNotBlank(la.LAT_MX_PostalCode__c))
                allZip.add(la.LAT_MX_PostalCode__c);
        }
        List<LAT_MX_PCD_PostalCode__c> zip = [SELECT Name FROM LAT_MX_PCD_PostalCode__c WHERE Name in: allZip];

        if(!zip.isEmpty()){
            for(LAT_MX_PCD_PostalCode__c z : zip){
                actualZip.add(z.name);
            }
        }

        for(LAT_Account__c la:latAccounts){
            if (String.isNotBlank(la.LAT_MX_PostalCode__c)){
                if(!actualZip.contains(la.LAT_MX_PostalCode__c))
                    la.addError('El Código Postal no se encuentra en la base de datos');
            }
        }
    }

    // Agregegado por Raul y Jose Luis ya que es un campo necesario para Compuarte
   /*
    public static void validarRFC(List <LAT_Account__c> latAccounts) {
        List<LAT_MX_RFC_Account__c> rfcList= [SELECT id,LAT_Account__c FROM LAT_MX_RFC_Account__c WHERE LAT_Account__c IN: latAccounts];
        Set<id> rfcSet = new Set<id>();

        if(rfcList != null && rfcList.size()>0){
            for(LAT_MX_RFC_Account__c r : rfcList){
                rfcSet.add(r.LAT_Account__c);
            }
            for(LAT_Account__c a : latAccounts) {
                if(!rfcSet.contains(a.id)){
                    a.addError('Se debe agregar al menos un RFC');
                }
           }
        }
        else{
            for(LAT_Account__c a : latAccounts){
                a.addError('Se debe agregar al menos un RFC');
            }
        }
    }
*/
    public static void sendForApproval(List <Account> newAccts ,Map<Id, Account> oldMap) {
        final String cadastradoJDE = 'Cliente cadastrado no JDE';
        final String modifiedInCRM = 'Modification requested in CRM';
        final String integrado = 'Integrado Compuarte';

        List <Approval.ProcessSubmitRequest> lstprocess = new List <Approval.ProcessSubmitRequest>();
        for (Account a : newAccts) {
            if (modifiedInCRM == a.Status__c && cadastradoJDE == oldMap.get(a.id).Status__c ) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(a.id);
                lstprocess.add(req);
            }
        }
        if (!lstprocess.isEmpty()) {
            List<Approval.ProcessResult> resultlist = Approval.process(lstprocess);
        }
    }

    // Sends the Id to Compuarte's WS
    @future (callout=true)
    public static void callOnTradeChangeWS (List <String> accts) {
        callOnTradeChangeWSSync(accts);
    }

    // Sends the Id to Compuarte's WS
    public static void callOnTradeChangeWSSync (List <String> accts) {
        LAT_DebugUtil debugUtil = new LAT_DebugUtil();
        debugUtil.setOrigin('LAT_MX_WS_notifyOnTradeChange');

        try {
            // Load the Id's list
            LAT_WS_MX_AccountOnTradeSchema.CentroConsumoListType ccListType = new LAT_WS_MX_AccountOnTradeSchema.CentroConsumoListType();
            LAT_WS_MX_AccountOnTradeSchema.CentroConsumo[] ccList = new List <LAT_WS_MX_AccountOnTradeSchema.CentroConsumo>();

            for (String a :  accts) {
                LAT_WS_MX_AccountOnTradeSchema.CentroConsumo cc = new LAT_WS_MX_AccountOnTradeSchema.CentroConsumo();
                cc.idsalesforce = a;
                ccList.add(cc);
            }

            ccListType.centroConsumo = ccList;

            LAT_WS_MX_AccountOnTrade.port request = new LAT_WS_MX_AccountOnTrade.port(); // Timeout and auth handled directly on LAT_MX_WS_OnTrade

            final String reqEndpoint = LAT_WS_Utils.getWSEndpointMXOnTradeNotify();

            debugUtil.addTitle('Request Start');
            debugUtil.addData(BREAK_LINE + 'Endpoint: ' + reqEndpoint + BREAK_LINE + BREAK_LINE);
            debugUtil.addData(BREAK_LINE + 'ccList: ' + ccList + BREAK_LINE + BREAK_LINE);
            debugUtil.addTitle('Request END');

            // Make request
            LAT_WS_MX_AccountOnTradeSchema.CentroConsumo[] response = request.NewOperation(ccListType);

            debugUtil.addTitle('Response Start');
            debugUtil.addData(BREAK_LINE + 'Response: ' + response + BREAK_LINE + BREAK_LINE);
            debugUtil.addTitle('Response END');

            // Save debug info and update customer
            debugUtil.insertDebug();
        } catch (DMLException e) {
            if (System.Test.isRunningTest()) return;
            System.Debug('DML PROBLEM');
            System.Debug(e);
            //customer.Status__c = 'Erro JDE';
            debugUtil = new LAT_DebugUtil();
            debugUtil.setOrigin('notifyOnTradeChange.EXCEPTION');
            debugUtil.addTitle('DML Exception!');
            debugUtil.addException(e);
            debugUtil.insertDebug();
        } catch (Exception e) {
            if (System.Test.isRunningTest()) return;
            System.Debug('e.getMessage(): ' + e.getMessage());
            //customer.Return_JDE_Integration__c = e.getMessage();
            //customer.Status__c = 'Erro JDE';
            debugUtil = new LAT_DebugUtil();
            debugUtil.setOrigin('notifyOnTradeChange.EXCEPTION');
            debugUtil.addTitle('Exception!');
            debugUtil.addException(e);
            debugUtil.insertDebug();
        }
    }

    public static void actualizarKAMUpdate(List <Account> newAccts ,Map<Id, Account> oldMap) {
        List<String> idOwners = new List<String>();
        Map<String,User> ownerManagerList = new Map<String,User>();

        for (Account a : newAccts) {
            if (a.OwnerId != oldMap.get(a.id).OwnerId )
                idOwners.add(a.OwnerId);
        }

        List<User> userManagerList = [SELECT id, Name, ManagerID from User WHERE id in :idOwners];
        for (User u : userManagerList){
            ownerManagerList.put(u.id,u);
        }

        String users = '';
        users = LAT_GeneralConfig__c.getInstance('MX_ON_TRADE_NO_KAM_USERS').LAT_Value__c;
        for (Account a : newAccts) {
            if (userManagerList.size() > 0) {
                if(users.contains(ownerManagerList.get(a.OwnerId).Name) && a.OwnerId == ownerManagerList.get(a.OwnerId).Id){
                    a.LAT_MX_CreditAndCollectionsExecutive__c = a.OwnerId;
                }else if(a.OwnerId != oldMap.get(a.id).OwnerId && ownerManagerList.get(a.OwnerId) != null){
                    a.LAT_MX_CreditAndCollectionsExecutive__c = ownerManagerList.get(a.OwnerId).ManagerID;
                }
            }
        }
    }

    public static void actualizarKAMInsert(List<Account> newAccts) {
        List<String> idOwners = new List<String>();
        Map<String,User> ownerManagerList = new Map<String,User>();

        for (Account a : newAccts) {
            idOwners.add(a.OwnerId);
        }

        List<User> managerList = [SELECT id, Name, ManagerID from User WHERE id in :idOwners];
        for (User u : managerList){
            ownerManagerList.put(u.id,u);
        }

        String users = '';
        users = LAT_GeneralConfig__c.getInstance('MX_ON_TRADE_NO_KAM_USERS').LAT_Value__c;

        for (Account a : newAccts) {
            if(users.contains(ownerManagerList.get(a.OwnerId).Name) && a.OwnerId == ownerManagerList.get(a.OwnerId).Id){
                a.LAT_MX_CreditAndCollectionsExecutive__c = a.OwnerId;
            }else if(ownerManagerList.get(a.OwnerId) != null){
                a.LAT_MX_CreditAndCollectionsExecutive__c = ownerManagerList.get(a.OwnerId).ManagerID;
            }
        }
    }

    public static void actualizarVisitas(List <Account> newAccts) {
        final String inactivo = 'Inactive Account';
        for (Account a : newAccts) {
            if (inactivo == a.Status__c)
                 a.Frequency_of_Visits__c = 'Sin Visitas';
        }
    }

    public static void calcularValorCalificacion(List <LAT_ACCOUNT__c> newAccts) {
        List<LAT_MX_SegmentacionRatios__c> regSeg = [Select BacardiFrom__c, BacardiTo__c,BacardiValue__c,BrandSelec__c,Booleanos__c,CalidadBateo__c,
                                                            CalidadBateoValue__c,Calificacion__c,ChampFrom__c,ChampTo__c,Champ_Value__c,CubaFrom__c,CubaTo__c,CubaValue__c,
                                                            DjInter__c,minPlatoFrom__c,minPlatoTo__c,minPlatoValue__c,NotaFrom__c,NotaTo__c,Promo__c,ResAcceso__c,Somelier__c,
                                                            Values__c,Visibilidad__c,WhiskFrom__c,WhiskTo__c,WhiskValue__c, HasRecognizedChef__c FROM LAT_MX_SegmentacionRatios__c];
        for (LAT_ACCOUNT__c a: newAccts) { 
            String tipoReg = darTipo(a);
            if(tipoReg != null && tipoReg != ''){
                a.LAT_Calificacion__c = darCalificacion(regSeg,a,tipoReg);
            }
        }
    }
    private static String darTipo(LAT_ACCOUNT__c latAc){
        if(latAc.LAT_SKUChampagne__c != null && latAc.LAT_SKUChampagne__c != '')
            return 'HEB';
        else if(latAc.LAT_CalidadBateo__c != null && latAc.LAT_CalidadBateo__c != '')
            return 'LEB';
        else if(latAc.LAT_PrecioMinPlatoFuerte__c != null && latAc.LAT_PrecioMinPlatoFuerte__c != '')
            return 'RESTAURANTE';
        else if(latAc.LAT_PrecioBacardi__c != null && latAc.LAT_PrecioBacardi__c != ''){
            return 'NIGHT CLUB';
        }
        return '';
    }
    private static String darCalificacion(List<LAT_MX_SegmentacionRatios__c> listSeg , LAT_Account__c acc, String tipo) {
        Decimal nota = 0;
        String cali = '';
        if(tipo == 'HEB') {
            for(LAT_MX_SegmentacionRatios__c seg: listSeg) {
                if(!acc.LAT_PromocionesPrecioPaquete__c) {
                    if(seg.values__c == 'HEB' && seg.promo__c != null) {
                        nota = nota + seg.Promo__c;
                    }
                }
                if (!acc.LAT_Branding__c) {
                    if(seg.values__c == 'HEB' && seg.BrandSelec__c != null) {
                        nota = nota + seg.BrandSelec__c;
                    }
                }
                if(seg.values__c == 'HEB' && Integer.valueOf(acc.LAT_CubaLibre__c) >= seg.CubaFrom__c  &&  Integer.valueOf(acc.LAT_CubaLibre__c) < seg.CubaTo__c ) {
                        nota = nota + seg.CubaValue__c;
                }
                if(seg.values__c == 'HEB' &&  Integer.valueOf(acc.LAT_SKUChampagne__c) >= seg.ChampFrom__c  &&  Integer.valueOf(acc.LAT_SKUChampagne__c) < seg.ChampTo__c ) {
                        nota = nota + seg.Champ_Value__c;
                }
            }
        }
        if(tipo == 'LEB') {
            for(LAT_MX_SegmentacionRatios__c seg: listSeg) {
                if(!acc.LAT_PromocionesPrecioPaquete__c) {
                    if(seg.values__c == 'LEB' && seg.promo__c != null ) {
                        nota = nota + seg.Promo__c;
                    }
                }
                if (!acc.LAT_Branding__c){
                    if(seg.values__c == 'LEB' && seg.BrandSelec__c != null ) {
                        nota = nota + seg.BrandSelec__c;
                    }
                }
                if(seg.values__c == 'LEB' && Integer.valueOf(acc.LAT_CubaLibre__c) >= seg.CubaFrom__c &&  Integer.valueOf(acc.LAT_CubaLibre__c) < seg.CubaTo__c ) {
                    nota = nota + seg.CubaValue__c;
                }
                if(seg.values__c == 'LEB' && seg.CalidadBateo__c != null &&  seg.CalidadBateo__c == acc.LAT_CalidadBateo__c) {
                    nota = nota + seg.CalidadBateoValue__c;
                }
            }
        }
        if(tipo == 'RESTAURANTE') {
            for(LAT_MX_SegmentacionRatios__c seg: listSeg) {
                if(acc.LAT_Somelier__c) {
                    if(seg.values__c == 'RESTAURANTE' && seg.Somelier__c != null) {
                        nota = nota + seg.Somelier__c;
                    }
                }
                if(!acc.LAT_Branding__c) {
                    if(seg.values__c == 'RESTAURANTE' && seg.BrandSelec__c != null) {
                        nota = nota + seg.BrandSelec__c;
                    }
                }
                if(seg.values__c == 'RESTAURANTE' && Integer.valueOf(acc.LAT_PrecioMinPlatoFuerte__c) >= seg.minPlatoFrom__c && Integer.valueOf(acc.LAT_PrecioMinPlatoFuerte__c) < seg.minPlatoTo__c) {
                    nota = nota + seg.minPlatoValue__c;
                } 
                if(seg.values__c == 'RESTAURANTE' && Integer.valueOf(acc.LAT_SKUWhiskies__c) >= seg.WhiskFrom__c &&  Integer.valueOf(acc.LAT_SKUWhiskies__c) < seg.WhiskTo__c ) {
                    nota = nota + seg.WhiskValue__c;
                }
                if(acc.LAT_MX_HasRecognizedChef__c) {
                    if(seg.values__c == 'RESTAURANTE' && seg.HasRecognizedChef__c != null) {
                        nota = nota + seg.HasRecognizedChef__c;
                    }
                }
            }
        }
        if(tipo == 'NIGHT CLUB') {
            for(LAT_MX_SegmentacionRatios__c seg: listSeg) {
                if(acc.LAT_DJInternacional__c) {
                    if(seg.values__c == 'NIGHT CLUB' && seg.DjInter__c != null){
                        nota = nota + seg.DjInter__c;
                    }
                }
                if(acc.LAT_RestriccionesAcceso__c) {
                    if(seg.values__c == 'NIGHT CLUB' && seg.ResAcceso__c != null) {
                        nota = nota + seg.ResAcceso__c;
                    }
                }
                if(acc.LAT_VisibilidadTailorMade__c) {
                    if(seg.values__c == 'NIGHT CLUB' && seg.Visibilidad__c != null) {
                        nota = nota + seg.Visibilidad__c;
                    }
                }
                if(seg.values__c == 'NIGHT CLUB' &&  Integer.valueOf(acc.LAT_PrecioBacardi__c) >= seg.BacardiFrom__c && Integer.valueOf(acc.LAT_PrecioBacardi__c) < seg.BacardiTo__c) {
                    nota = nota + seg.BacardiValue__c;
                }
            }
        }
        for(LAT_MX_SegmentacionRatios__c seg: listSeg) {
            if(seg.values__c != null && seg.values__c == tipo && nota >= seg.NotaFrom__c && nota <= seg.NotaTo__c) {
                cali = seg.Calificacion__c;
            }
        }
        system.debug('NicoBan:'+nota);
        return cali;
    }

    /**
     * if in a insert/update a Kam atending was not setted, set the default to the owner (validating the profile to match filter criteria)
     * @param newAccts - accounts to set fields to
     */
    public static void setAttendingExecutive(List <LAT_ACCOUNT__c> newAccts, Map<Id, Account> accById) {
        for (LAT_ACCOUNT__c a: newAccts) {
            Account currAcc = accById.get(a.LAT_AccountID__c);
            if ((currAcc.RecordType.DeveloperName == 'LAT_MX_ACC_OnTrade') && ((currAcc.Owner.Profile.Name == 'LAT_MX2_OnPremise') || (currAcc.Owner.Profile.Name == 'LAT_MX2_Vendedor_OnPremise') || (currAcc.Owner.Profile.Name == 'LAT_MX2_Coordinador_CRM'))){
                if (a.LAT_MX_AttendingKAM__c == null) {
                    a.LAT_MX_AttendingKAM__c = accById.get(a.LAT_AccountID__c).OwnerId;
                }
            }
        }
    }

    /**
     * Share the account with the attending Kam
     */
    public static void shareAccountWithAttendingKam(List <LAT_ACCOUNT__c> newAccts,Map<Id, LAT_ACCOUNT__c> accOldMap, Map<Id, Account> accById) {
        List<AccountShare> sharings = new List<AccountShare>();
        for (LAT_ACCOUNT__c a: newAccts) {
            // if it's an insert, kam different from owner or the Kam was changed create a new share

            system.debug('Owner +++ ' + accById.get(a.LAT_AccountID__c).OwnerId);
            system.debug('oldMap +++ ' + accOldMap.get(a.Id));
            system.debug('a.AttendingKam +++ ' + a.LAT_MX_AttendingKAM__c);

            if ((a.LAT_MX_AttendingKAM__c != null)
                && (((accOldMap.get(a.Id) == null) && (a.LAT_MX_AttendingKAM__c != accById.get(a.LAT_AccountID__c).OwnerId))
                || ((accOldMap.get(a.Id) != null) && ((accOldMap.get(a.Id).LAT_MX_AttendingKAM__c != a.LAT_MX_AttendingKAM__c) && a.LAT_MX_AttendingKAM__c != accById.get(a.LAT_AccountID__c).OwnerId)))){

                AccountShare share = new AccountShare();
                share.AccountAccessLevel = 'Read';
                share.AccountId =  a.LAT_AccountID__c;
                share.UserOrGroupId = a.LAT_MX_AttendingKAM__c;
                share.OpportunityAccessLevel = 'Read';
                sharings.add(share);
            }
        }

        // TODO: Improve error handling
        try {
            insert sharings;
        } catch (Exception e) {
            system.debug('Could not Insert Sharing: ' + e.getStackTraceString());
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: FieldMissingDocumentsOnTradeNewAccount
    * Descripcion: Completo el campo 'Missing Documents' cuando se inserta un Account OnTrade
    * Desarrollador: Isabel Gabard
    * Fecha: 07/01/2021
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void FieldMissingDocumentsOnTradeNewAccount(List<LAT_Account__c> triggerNew, map<Id,LAT_Account__c> oldMap) {
        System.debug('%%%%%% entramos en FieldMissingDocumentsOnTradeNewAccount');
        System.debug('%%%%%% entramos en FieldMissingDocumentsOnTradeNewAccount triggerNew '+triggerNew);
        System.debug('%%%%%% entramos en FieldMissingDocumentsOnTradeNewAccount oldMap '+oldMap);
        
        List<Id> accsId = new List<Id>();
        List<LAT_Account__c> listAccounts = new List<LAT_Account__c>();
        for(LAT_Account__c acc: triggerNew){
            if(OldMap.isEmpty() || (acc.LAT_TipoCentro__c != oldMap.get(acc.id).LAT_TipoCentro__c)){
                listAccounts.add(acc);
                accsId.add(acc.LAT_Accountid__c);
            }
        }
        Map<Id, Account> accs = new Map<Id, Account>([Select Id, LAT_MX_MissingDocuments__c From Account Where Id IN :accsId And RecordType.DeveloperName = 'LAT_MX_ACC_OnTrade']);

        if (!listAccounts.isEmpty()) {
            list<LAT_MX_CS003_OnTradeAccountDocuments__mdt> listAccountDocs = [Select MasterLabel, DeveloperName, LAT_MX_RequiredForCenter__c
                                                                                From LAT_MX_CS003_OnTradeAccountDocuments__mdt];
            set<String> setCenters = new set<String>();
            map<String, LAT_MX_CS003_OnTradeAccountDocuments__mdt> mapCS = new map<String, LAT_MX_CS003_OnTradeAccountDocuments__mdt>();

            for(LAT_MX_CS003_OnTradeAccountDocuments__mdt accDoc: listAccountDocs){
                setCenters.add(accDoc.LAT_MX_RequiredForCenter__c);
            }
            
            for (LAT_Account__c acc : listAccounts) {
                if (accs.containsKey(acc.LAT_Accountid__c)) {
                    list<String> listMissingDocs = new list<String>();      
                    System.debug('%%%% setCenters : '+ setCenters);
                    System.debug('%%%% acc.LAT_TipoCentro__c : '+ acc.LAT_TipoCentro__c);
                    String MissingDocs = '';       
                    if(setCenters.contains(acc.LAT_TipoCentro__c)){
                        String MissingDoc;
                        for(LAT_MX_CS003_OnTradeAccountDocuments__mdt accDoc: listAccountDocs){
                            System.debug('%%%% accDoc.LAT_MX_RequiredForCenter__c : '+ accDoc.LAT_MX_RequiredForCenter__c);
                            
                            if(accDoc.LAT_MX_RequiredForCenter__c == acc.LAT_TipoCentro__c){
                                MissingDoc = accDoc.MasterLabel + ' (' + accDoc.DeveloperName.substring(0, 7) + ')';
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
                    accs.get(acc.LAT_Accountid__c).LAT_MX_MissingDocuments__c = MissingDocs;
                }
            }
            update accs.values();
        }
    }

    // Metodo para before update de Account
    // Procesa accounts a las que se aprobo la inhabilitacion('Inactive Approved')  
    // y accounts a las que se le rechazo la inhabilitacion('Inactive Rejected')
    public static void inactiveAccounts(List<Account> accs) {
        Map<Id, Account> accountApprovedMap = new Map<Id, Account>();
        Map<Id, Account> accountRejectedMap = new Map<Id, Account>();
        for (Account acc : accs) {
            if (acc.status__c == 'Inactive Approved') {
                acc.status__c = 'Inactive Account';
                accountApprovedMap.put(acc.LAT_ACCOUNT__c, acc);
            } else if (acc.Status__c == 'Inactive Rejected') {
                accountRejectedMap.put(acc.LAT_ACCOUNT__c, acc);
            }
        }
        if (!accountApprovedMap.isEmpty()) {
            inactiveAccountsApproved(accountApprovedMap);
        }
        if (!accountRejectedMap.isEmpty()) {
            inactiveAccountsRejected(accountRejectedMap);
        }
    }

    // Actualiza las cuentas a las que se aprobo la inhabilitacion y sus objetos relacionados y manda mails
    private static void inactiveAccountsApproved(Map<Id, Account> accountApprovedMap) {
        List<LAT_ACCOUNT__c> latAccs = new List<LAT_ACCOUNT__c>();
        for (LAT_Account__c latAcc : [Select id from LAT_ACCOUNT__c where id IN : accountApprovedMap.keyset()]) {
            latAcc.LAT_ID_Status__c = 'Inactivo'; 
            latAccs.add(latAcc);
        }
        update latAccs;

        List<LAT_MX_RFC_Account__c> listAccountRFCs = new List<LAT_MX_RFC_Account__c>();
        for (Id latAccId : accountApprovedMap.keyset()) {
            List<LAT_MX_RFC_Account__c> accountRFCs = [SELECT id FROM LAT_MX_RFC_Account__c WHERE LAT_ACCOUNT__c = :latAccId];
            if (accountRFCs.size() > 0) {
                listAccountRFCs.addAll(accountRFCs);
            }  
        }
        delete listAccountRFCs;

        List<Id> cycExecutive = new List<Id>();
        for (Account acc : accountApprovedMap.values()) {
            cycExecutive.add(acc.LAT_MX_CreditAndCollectionsExecutive__c);
        }
        Map<Id, User> cycExecutiveEmail = new Map<Id, User>([Select Email From User Where Id IN :cycExecutive]);
        for (Account acc : accountApprovedMap.values()) {
            List<String> toAddresses = new List<String>();
            if (acc.LAT_MX_CreditAndCollectionsExecutive__c != null) {
                toAddresses.add(cycExecutiveEmail.get(acc.LAT_MX_CreditAndCollectionsExecutive__c).Email);
            }

            String[] configEmails = LAT_GeneralConfigDao.getValueAsStringArray('MX_ON_TRADE_INACTIVATION_RECIPIENTS', ';');
            if(configEmails != null && configEmails.size()>0)toAddresses.addAll(configEmails);
            
            sendEmail(toAddresses, acc);
        }
    }
    // Actualiza las cuentas a las que se rechazo la inhabilitacion, se vuelve al estado previo
    private static void inactiveAccountsRejected(Map<Id, Account> accountRejectedMap) {
        List<Account> accounts = new List<Account>();
        for (LAT_Account__c latAcc : [Select id, LAT_Status_Before_Approval__c 
                                    from LAT_ACCOUNT__c where id IN : accountRejectedMap.keyset()]) {
            Account acc = accountRejectedMap.get(latAcc.id);
            acc.Status__c = latAcc.LAT_Status_Before_Approval__c; 
        }
        update accounts;
    }
    @TestVisible
    private static void sendEmail(List<String> toAddresses, Account acc) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setTargetObjectId(UserInfo.getUserId()); 
        mail.setSaveAsActivity(false); 
        mail.setSubject('Cuenta Inactivada: ' + acc.Name);
        String msg = 'Se inactivo la siguiente cuenta: ';
        msg += '\n\n' + acc.name;
        msg += '\n\nhttps://' + URL.getSalesforceBaseUrl().getHost() + '/'+ acc.id;
        mail.setPlainTextBody(msg);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    @future (callout=true)
    public static void callOnInhabilitar(Set<Id> acctIds) {
        List<Account> accts = [Select Id, Regional_Manager__c, Status__c From Account Where Id IN :acctIds];
        for (Account acc : accts) {
            if (acc.Status__c == 'Pending Inactivation Approval') {
                // create the new approval request to submit
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please approve.');
                req.setNextApproverIds(new List<Id>{acc.Regional_Manager__c});
                req.setObjectId(acc.Id);
                // submit the approval request for processing
                Approval.ProcessResult result = Approval.process(req);
                System.debug('Submitted for approval successfully: '+result.isSuccess());
            }
        }
    }
}