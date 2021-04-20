public with sharing class ASI_HK_CRM_OasisWSSecurity {
	
	public class UsernameToken {
		
		public String Username;
		public String Password;
		private String[] Username_type_info = new String[]{'Username','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] Password_type_info = new String[]{'Password','http://www.w3.org/2001/XMLSchema','string','1','1','false'};
		private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
		private String[] field_order_type_info = new String[]{'Username', 'Password'};
		
		public UsernameToken(String username, String password) {
			this.Username = username;
			this.Password = password;
		}
	}
	
	public class SecurityType {
		
		public String wsuNamespace = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd';
		public UsernameToken UsernameToken;
		private String[] wsuNamespace_att_info = new String[]{'xmlns:wsse'};
		private String[] UsernameToken_type_info = new String[]{'UsernameToken',wsuNamespace,'UsernameToken','1','1','false'};
		private String[] apex_schema_type_info = new String[]{wsuNamespace,'true','false'};
		private String[] field_order_type_info = new String[]{'UsernameToken'};
		
		public SecurityType(String username, String password) {
			this.UsernameToken = new UsernameToken(username, password);
		}
	}
}