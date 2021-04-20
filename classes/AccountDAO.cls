/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Account.
* NAME: AccountDAO.CLS
* AUTHOR: CARLOS CARVALHO                            DATE: 26/04/2012
*
* MAINTENANCE: Alteração SELECT com inclusão dos campos Regional_Manager__c,
*              ParentId, Parent.Regional_Manager__c, Sub_Channel_Rating__c
* AUTHOR: MARCOS DOBROWOLSKI                         DATE: 26/12/2012
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013
********************************************************************************/
public with sharing class AccountDAO 
{
  
  private static final AccountDAO instance = new AccountDAO();
  private Set< Id > setRecTypeAcc = getIds();
  //T
  private Set< Id > getIds(){
    Set< Id > lSet = new Set< Id >();
    /*lSet.add( RecordTypeForTest.getRecType( 'Account', 'Eventos'));
    lSet.add( RecordTypeForTest.getRecType( 'Account', 'Off_Trade'));
    lSet.add( RecordTypeForTest.getRecType( 'Account', 'On_Trade'));*/

    for(RecordType rt :[SELECT Id, IsActive, SobjectType, Name, DeveloperName FROM RecordType WHERE IsActive=True AND SobjectType='Account']){
        if(rt.DeveloperName=='ACC_1_OffTrade_ARG'){
          lSet.add(rt.Id);
        }else if(rt.DeveloperName=='ACC_2_OffTrade_URU'){
          lSet.add(rt.Id);  
        }else if(rt.DeveloperName=='ACC_3_OnTrade_ARG'){
          lSet.add(rt.Id);
        }else if(rt.DeveloperName=='ACC_4_OnTrade_URU'){
          lSet.add(rt.Id);
        }else if(rt.DeveloperName=='ACC_5_Events_ARG'){
          lSet.add(rt.Id);
        }else if(rt.DeveloperName=='ACC_6_Events_URU'){
          lSet.add(rt.Id);
        }else if(AP01_Account_BR.BR_RECORDTYPES.Contains(rt.DeveloperName)){
          lSet.add(rt.Id);
        }
    }
    return lSet;
  }
  /*Construtor privado para impedir a criação de instâncias dessa classe.*/
  private AccountDAO()
  {
  }
  
  /**
  * Método responsável por prover a instância dessa classe.
  */
  public static AccountDAO getInstance()
  {
    return instance;
  }
  /**
   * Description: Recupera todas as contas onde o proprietario do planejamento com o ID dentro da lista passada como parametro. 
   * @param idOwnersPlanejamneto (IDS de Proprietário da Conta).
   */
  public List<Account> getListAccountByIdsOwners(List<String> idOwnersPlanejamento)
  {
    /*Declaração de variáveis.*/
    List<Account> listAccount = null;
    
    listAccount = [ SELECT Id, Name, Channel__c, Regional__c, Frequency_of_Visits__c, OwnerId, 
        Regional_Manager__c, ParentId, Parent.Regional_Manager__c, Sub_Channel_Rating__c, 
        Sub_Channel_Rating__r.Name, Parent.OwnerId
        FROM Account WHERE OwnerId =: idOwnersPlanejamento AND Rating <> 'Cliente inativo' AND Status__c <> 'Novo cadastro' AND Status__c <> 'Não aprovado'
        AND RecordTypeId =: setRecTypeAcc];
            
    return listAccount;
  }
}