/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Tipo_de_Documento__c.
* NAME: TipoDocumentoDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 01/08/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
public with sharing class TipoDocumentoDAO {
	
	private static final TipoDocumentoDAO  instance = new TipoDocumentoDAO();
	
	//Construtor privado para impedir a criação de instâncias dessa classe.
	private TipoDocumentoDAO()
	{
	} 
	
	//Método responsável por prover a instância dessa classe.
	public static TipoDocumentoDAO getInstance()
	{
		return instance;
	}
	
	private Id idRecTypeTD = RecordTypeForTest.getRecType('Tipo_de_Documento__c', 'Tipo_de_Documento');
	
	public List<Tipo_de_Documento__c> getListTipoDocumento( String idContrato ){
		List<Tipo_de_Documento__c> listTipoDocumento = new List<Tipo_de_Documento__c>();
		
		listTipoDocumento = [ SELECT Id,
									 Codigo_do_Documento__c,
									 LastModifiedById,
									 LastModifiedDate
									 FROM Tipo_de_Documento__c
									 WHERE LAT_Contract__c =: idContrato
									 AND RecordTypeId =: idRecTypeTD
							];
		
		return listTipoDocumento;
	}
}