/*
* LAT_ContractDAHandlerInterface
* Author: Martin Prado (martin@zimmic.com)
* Date: 03/31/2017
*/
public with sharing class LAT_ContractDAHandlerInterface {

  //Constructor
  public LAT_ContractDAHandlerInterface() {}

  @future (callout=true)
  public static void createNewDA(Id contractId) {

    List<LAT_Contract2__c> contracts =  [SELECT Name, owner.Email, StartDate__c, status__c, account__r.Client_code_AN8__c, account__r.LAT_BR_RegionalClientOnPremise__c, account__r.name FROM LAT_Contract2__c where id =: contractId];
    LAT_Contract2__c contract;
    if(contracts.size()>0) {
      contract = contracts.get(0);
    }

    String regName = contract.account__r.LAT_BR_RegionalClientOnPremise__c;
    String workflowType = '';
    List<LAT_RegionalSupervisor__c> ars = [SELECT AssistenteRegional__c, AssistenteRegional__r.Email, LAT_RegionalClientOnPremise__c, Workflowtype__c FROM LAT_RegionalSupervisor__c where LAT_RegionalClientOnPremise__c =:regName and Workflowtype__c  != '' ];

    // if(){
    //   workflowType = ars.Workflowtype__c;
    // }

    workflowType = (ars.size()>0) ? ars.get(0).Workflowtype__c : '';

    List<Date> datesFromTO = LAT_FiscalYearHelper.getInstance().getFiscalYearFromTo(contract.StartDate__c);
    String fiscalYear = LAT_FiscalYearHelper.getInstance().getFiscalYearCode(contract.StartDate__c);

    LAT_ContractsCalculations cc = new LAT_ContractsCalculations();
    Double contractValue = cc.getQuarterInformation(contractId, datesFromTO.get(0), datesFromTO.get(1) );
  if(contractValue == 0) {
    contractValue = 0.1;
  }
    System.debug('=======================\n contractValue: ' + contractValue+ '\n=======================' );



    // Set request Params
    LAT_PaymentCreateDA.WSCriarDASoapBindingQSPort request = new LAT_PaymentCreateDA.WSCriarDASoapBindingQSPort();
    request.timeout_x = 120000;

    // Create response fields
    LAT_PaymentCreateDA.SdtMsg message =  new LAT_PaymentCreateDA.SdtMsg();
    Integer Domnro = null;

    //
    LAT_PaymentCreateDA.WSCriarDA_ExecuteResponse_element responseHandler = new LAT_PaymentCreateDA.WSCriarDA_ExecuteResponse_element();
    LAT_PaymentCreateDA.SDTDA newDA =  generateDA(contract.account__r.Name, fiscalYear, contract.account__r.Client_code_AN8__c, contractValue, workflowType );
    System.debug('=======================\n newDA: ' + newDA+ '\n=======================' );

    if(!Test.isRunningTest()) {

     // to do, add try catch
      responseHandler = request.Execute(1, 81, newDA);

      System.debug('=======================\n responseHandler: ' + responseHandler+ '\n=======================' );
      processMEResponse(responseHandler, contractId,  workflowType, fiscalYear, contract, contractValue);
    }

  }

  private static LAT_PaymentCreateDA.SDTDA generateDA(String cnpj, String fiscalYear, String an8, Double contractValue, String daType){
    LAT_PaymentCreateDA.SDTDA da = new LAT_PaymentCreateDA.SDTDA();
    da.TdoCod = daType;
    da.DomDes = an8 + ' || ' + fiscalYear;
    da.DomDesRes = an8 + ' || ' + cnpj;
    da.DomObj = 'Contrato dose';
    da.DomVal = contractValue * 1.05;//'valor + 5%';
    da.DomDatLim = date.today();//'data do dia';
    da.DomDatCnc =  date.today();//'data do dia';
    da.DomUsrCri = 'BILINSKY';
    da.DomMer = 'DOM';
    da.DomArm = 'NCT';
    da.PrjCod = '00195';
    LAT_PaymentCreateDA.Acao_element action;
    LAT_PaymentCreateDA.SDTDA_AcaoItem[] items = new LAT_PaymentCreateDA.SDTDA_AcaoItem[]{};
    LAT_PaymentCreateDA.SDTDA_AcaoItem actionItem = new LAT_PaymentCreateDA.SDTDA_AcaoItem();
    actionItem.NtaCod = 'TA';
    actionItem.GraCod = 'NC';
    actionItem.SgaCod = '-1';
    actionItem.AcaCod = 54;
    actionItem.DraPerAlo = 100;
    items.add(actionItem);
    da.Acao = new LAT_PaymentCreateDA.Acao_element();
    da.Acao.AcaoItem = items;
    return da;
  }


  /**
  * processMEResponse
  *
  */
  private static void processMEResponse(LAT_PaymentCreateDA.WSCriarDA_ExecuteResponse_element message, String contractId, String type, String fiscalYear, LAT_Contract2__c contract, Double value){
    Integer daNewNumber;

    String messageText = message.SdtMsg.SdtMsg_SdtMsgItem[0].Mensagem;
    String code = message.SdtMsg.SdtMsg_SdtMsgItem[0].codigo;

    System.debug('=======================\n code: ' + code+ '\n=======================' );
    System.debug('=======================\n messageText: ' + messageText+ '\n=======================' );

    if(code == '00') {

      // Set request Params
      LAT_PaymentApproveReproveDA.WSAprovarReprovarDASoapBindingQSPort request = new LAT_PaymentApproveReproveDA.WSAprovarReprovarDASoapBindingQSPort();
      request.timeout_x = 120000;

      LAT_PaymentApproveReproveDA.SdtMsg messageAp =  new LAT_PaymentApproveReproveDA.SdtMsg();
      LAT_PaymentApproveReproveDA.WSAprovarReprovarDA_Execute_element responseHandler = new LAT_PaymentApproveReproveDA.WSAprovarReprovarDA_Execute_element();

      // to do, add try catch
      messageAp = request.Execute(1, 81, type , integer.valueof(message.Domnro), 'A','BILINSKY');
      // if(action == 'A'){
      //  saveDAStatus(Integer.valueof(daNumber), type, 'Ativo', contractId);
      // } else {
      //  saveDAStatus(Integer.valueof(daNumber), type, 'Inativo', contractId);
      // }

      System.debug('=======================\n messageAp: ' + messageAp+ '\n=======================' );

      daNewNumber = message.Domnro;
      LAT_ContractDA__c da = new LAT_ContractDA__c();
      da.Fiscal_Year__c = fiscalYear;
      da.Type__c = type;
      da.Contract__c = contractId;
      da.DANumber__c = daNewNumber;
      da.Value__c = value * 1.05;
      da.Status__c = 'Ativo';
      insert da;

      runApprovalProcess(contractId);

    } else {
      contract.status__c = 'Novo Contrato';
      contract.ProcessStatus__c = 'Erro Aprovação';

      String subject = 'Erro Criação WF para o Contrato - '+ ' '+contract.Name;
      String html = 'Erro Criação WF para o Contrato - '+ ' '+contract.Name+'<br/><br/><br/>Mensagem de erro: '+ code+' '+messageText;

      sendTradeNotification(subject, html , contract.owner.Email);

      update contract;
    }

  }

  /**
  * runApprovalProcess
  * Change the DA status on ME
  * @param contractID = 200
  */
  @future
  public static void runApprovalProcess(String contractId) {
    Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
    submitRequest.setComments('Submitting contract for approval.');
    submitRequest.setObjectId(contractId);
    Approval.ProcessResult result = Approval.process(submitRequest);
  }


  /**
  * activateDeactivateDA
  * Change the DA status on ME
  * @param daNumber = 200
  * @param type = SP
  * @param action 'R' to deactivate or 'A' to activate
  */
  @future (callout=true)
  public static void activateDeactivateDA(String daNumber, String type, String action, String fiscalYear, String contractId ){

    // Set request Params
    LAT_PaymentApproveReproveDA.WSAprovarReprovarDASoapBindingQSPort request = new LAT_PaymentApproveReproveDA.WSAprovarReprovarDASoapBindingQSPort();
    request.timeout_x = 120000;

    LAT_PaymentApproveReproveDA.SdtMsg message =  new LAT_PaymentApproveReproveDA.SdtMsg();
    LAT_PaymentApproveReproveDA.WSAprovarReprovarDA_Execute_element responseHandler = new LAT_PaymentApproveReproveDA.WSAprovarReprovarDA_Execute_element();

    // to do, add try catch
    if (!Test.isRunningTest()) {
      message = request.Execute(1, 81, type , integer.valueof(daNumber), action,'BILINSKY');
      System.debug('=======================\n message: ' + message+ '\n=======================' );
    }
    if(action == 'A'){
      saveDAStatus(Integer.valueof(daNumber), type, 'Ativo', contractId);
    } else {
      saveDAStatus(Integer.valueof(daNumber), type, 'Inativo', contractId);
    }



  }

  /**
  * cancelDA
  * Change the DA status on ME
  * @param daNumber = 200
  * @param type = SP
  * @param action 'R' to deactivate or 'A' to activate
  */
  @future (callout=true)
  public static void cancelDA(String contractId){

    List<LAT_ContractDA__c> contractDas = [SELECT Contract__c,DANumber__c,Fiscal_Year__c,Status__c,Type__c,Value__c FROM LAT_ContractDA__c where contract__c =: contractId and Status__c = 'Ativo' order by createddate desc ];
    LAT_ContractDA__c con;
    if(contractDas.size()>0){
      con = contractDas.get(0);
      Integer daNumber = Integer.valueOf(con.DANumber__c);
      String type = con.Type__c;
      // Set request Params
      LAT_PaymentCancelDA.WSCancelarEncerrarDASoapBindingQSPort request = new LAT_PaymentCancelDA.WSCancelarEncerrarDASoapBindingQSPort();
      request.timeout_x = 120000;

      LAT_PaymentCancelDA.SdtMsg message =  new LAT_PaymentCancelDA.SdtMsg();
      LAT_PaymentCancelDA.WSCancelarEncerrarDA_ExecuteResponse_element responseHandler = new LAT_PaymentCancelDA.WSCancelarEncerrarDA_ExecuteResponse_element();

      // to do, add try catch
      message = request.Execute(1, 81, type , daNumber, 'C','BILINSKY');

      System.debug('=======================\n message: ' + message+ '\n=======================' );


      String messageText = message.SdtMsg_SdtMsgItem[0].Mensagem;
      String code = message.SdtMsg_SdtMsgItem[0].codigo;

      System.debug('=======================\n code: ' + code+ '\n=======================' );
      System.debug('=======================\n messageText: ' + messageText+ '\n=======================' );

      saveDAStatus(Integer.valueof(daNumber), type, 'Cancelado', contractId);
    }

  }


  /**
  * saveDAStatus
  * Change the DA status on salesforce.
  * @param daNumber = 200
  * @param type = SP
  * @param status
  * @param contractId
  */
  private static void saveDAStatus(Integer daNumber, String type, String status, String contractId) {
    List<LAT_ContractDA__c> das = [Select id, status__c from LAT_ContractDA__c where Type__c =:type and DANumber__c =:daNumber and contract__c =:contractId  ];
    if(das.size()>0) {
      LAT_ContractDA__c da = das.get(0);
      da.status__c = status;
      update da;
    }
  }

  public static void sendTradeNotification(String subject, String html, String ownerMail){
    String[] emails = LAT_GeneralConfigDao.getValueAsStringArray('LAT_CONTRACT_TRADE_EMAIL', ',');

    List<GroupMember>  groupMembers = [SELECT GroupId,UserOrGroupId, group.developerName FROM GroupMember where group.developerName= 'LAT_BR_ContractTrade'];
    if(!groupMembers.isEmpty()){

      Set<Id> uIds = new Set<Id>();
      List<User> userToNotify = new List<User>();

      for(GroupMember gm : groupMembers){
        uIds.add(gm.UserOrGroupId);
      }


      userToNotify = [Select email FROM User where id in:uIds];

      if(userToNotify.size()>0){
        String[] mailAddress = new String[]{};
        for(User u : userToNotify){
          mailAddress.add(u.email);
        }

        mailAddress.add(ownerMail);
        //mailAddress.add('martin@zimmic.com');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
       //  String[] toAddresses = ;
        email.setToAddresses( mailAddress );
        email.setSaveAsActivity(false);
        email.setHtmlBody(html);
        email.setBccSender(false);
        email.setSubject(subject);
        email.setUseSignature(false);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});


      }
    }
  }



}