public with sharing class ASI_HK_CRM_HoverPopupInfoData {
	public String dataId { get; set; }
	public String title { get; set; }
	public List<ASI_HK_CRM_HoverPopupInfoDataRow> tableRow { get; set; }
	public Map<String, Object> tableData { get; set; }
	
	public ASI_HK_CRM_HoverPopupInfoData(String title, List<ASI_HK_CRM_HoverPopupInfoDataRow> tableRow, Map<String, Object> tableData) {
		this.title = title;
		this.tableRow = tableRow;
		this.tableData = tableData;
	}
	
	public with sharing class ASI_HK_CRM_HoverPopupInfoDataRow {
		public String rowId { get; set; }
		public String label { get; set; }
		
		public ASI_HK_CRM_HoverPopupInfoDataRow(String rowId, String label) {
			this.rowId = rowId;
			this.label = label;
		}
	}
}