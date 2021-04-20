public with sharing class ASI_MFM_SG_HoverPopupInfoData {
	public String dataId { get; set; }
	public String title { get; set; }
	public List<ASI_MFM_SG_HoverPopupInfoDataRow> tableRow { get; set; }
	public Map<String, Object> tableData { get; set; }
	
	public ASI_MFM_SG_HoverPopupInfoData(String title, List<ASI_MFM_SG_HoverPopupInfoDataRow> tableRow, Map<String, Object> tableData) {
		this.title = title;
		this.tableRow = tableRow;
		this.tableData = tableData;
	}
	
	public with sharing class ASI_MFM_SG_HoverPopupInfoDataRow {
		public String rowId { get; set; }
		public String label { get; set; }
		
		public ASI_MFM_SG_HoverPopupInfoDataRow(String rowId, String label) {
			this.rowId = rowId;
			this.label = label;
		}
	}
}